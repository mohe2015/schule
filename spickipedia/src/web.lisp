(in-package :spickipedia.web)

(declaim (optimize (debug 3)))

(defclass <web> (<app>) ())

(defvar *web* (make-instance '<web>))

(clear-routing-rules *web*)

(defmacro with-user (&body body)
  `(if (gethash :user *session*)
       (let ((user (find-dao 'user :id (gethash :user *session*))))
         ,@body)
       (throw-code 401)))

(defun random-base64 () (usb8-array-to-base64-string (random-data 64)))

(defmacro with-group (groups &body body)
  `(if (member (user-group user) ,groups)
       (progn ,@body)
       (throw-code 403)))

(defparameter *version* "1")

(defun valid-csrf ()
  (string= (my-session-csrf-token *session*)
           (assoc "csrf_token" (request-query-parameters *request*))))

(defun hash-contents (content)
  (byte-array-to-hex-string
   (digest-sequence :sha256 (ascii-string-to-byte-array content))))

(defun hash-contents-vector (content)
  (byte-array-to-hex-string (digest-sequence :sha256 content)))

(defun cache ()
  (setf (getf (response-headers *response*) :cache-control)
        "public, max-age=0")
  (setf (getf (response-headers *response*) :vary) "Accept-Encoding"))

(defun cache-forever ()
  (setf (getf (response-headers *response*) :cache-control) "max-age=31556926")
  (setf (getf (response-headers *response*) :vary) "Accept-Encoding")
  (setf (getf (response-headers *response*) :etag) *version*))

(defmacro with-cache-forever (&body body)
  `(progn
     (cache-forever)
     (if (equal (gethash "if-none-match" (request-headers *request*)) *version*)
         (throw-code 304)
         (progn ,@body))))

(defmacro with-cache (key &body body)
  `(progn
     (cache)
     (let* ((key-hash (hash-contents ,key)))
       (if (equal (gethash "if-none-match" (request-headers *request*))
                  (concatenate 'string "W/\"" key-hash "\""))
           (throw-code 304)
           (progn
             (setf (getf (response-headers *response*) :etag)
                   (concatenate 'string "W/\"" key-hash "\""))
             (progn ,@body))))))

(defmacro with-cache-vector (key &body body)
  `(progn
     (cache)
     (let* ((key-hash (hash-contents-vector ,key)))
       (if (equal (gethash "if-none-match" (request-headers *request*))
                  (concatenate 'string "W/\"" key-hash "\""))
           (throw-code 304)
           (progn
             (setf (getf (response-headers *response*) :etag)
                   (concatenate 'string "W/\"" key-hash "\""))
             (progn ,@body))))))

(defun basic-headers ()
  (setf (getf (response-headers *response*) :x-frame-options) "DENY")
  (setf (getf (response-headers *response*) :content-security-policy)
        "default-src 'none'; script-src 'self'; img-src * data: ; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com; frame-ancestors 'none';")
  (setf (getf (response-headers *response*) :x-xss-protection) "1; mode=block")
  (setf (getf (response-headers *response*) :x-content-type-options) "nosniff")
  (setf (getf (response-headers *response*) :referrer-policy) "no-referrer"))

(defmacro my-defroute (method path permissions params content-type &body body)
  `(defroute (,path :method ,method) (&key ,@params) (basic-headers)
	     (setf (getf (response-headers *response*) :content-type) ,content-type)
	     (with-connection (db)
	       ,(if permissions
		    `(with-user (with-group ',permissions ,@body))
		    `(progn ,@body)))))

(my-defroute :get "/api/wiki/:title" (:admin :user :anonymous) (title) "application/json"
  (let* ((article (find-dao 'wiki-article :title title)))
    (if (not article)
        (throw-code 404))
    (let ((revision
           (select-dao 'wiki-article-revision (where (:= :article article))
		       (order-by (:desc :id)) (limit 1))))
      (if (not revision)
          (throw-code 404))
      (encode-json-to-string
       `((content
          . ,(clean (wiki-article-revision-content (car revision))
		    *sanitize-spickipedia*))
         (categories
          . ,(mapcar #'(lambda (v) (wiki-article-revision-category-category v))
                     (retrieve-dao 'wiki-article-revision-category :revision
				   (car revision)))))))))

(my-defroute :get "/api/revision/:id" (:admin :user) (id) "application/json"
  (let* ((revision (find-dao 'wiki-article-revision :id (parse-integer id))))
    (if (not revision)
        (throw-code 404))
    (encode-json-to-string
     `((content
        . ,(clean (wiki-article-revision-content revision)
		  *sanitize-spickipedia*))
       (categories
        . ,(list-to-array
            (mapcar #'(lambda (v) (wiki-article-revision-category-category v))
                    (retrieve-dao 'wiki-article-revision-category :revision
				  revision))))))))

(defun list-to-array (list) (make-array (length list) :initial-contents list))

(my-defroute :get "/api/previous-revision/:the-id" (:admin :user) (the-id) "application/json"
  (let* ((id (parse-integer the-id))
         (query
          (dbi.driver:prepare *connection*
                              "SELECT id FROM wiki_article_revision WHERE article_id = (SELECT article_id FROM wiki_article_revision WHERE id = ?) and id < ? ORDER BY id DESC LIMIT 1;"))
         (result (dbi.driver:execute query id id))
         (previous-id (getf (dbi.driver:fetch result) :|id|)))
    (if previous-id
        (let ((revision (find-dao 'wiki-article-revision :id previous-id)))
          (encode-json-to-string
           `((content
              . ,(clean (wiki-article-revision-content revision)
			*sanitize-spickipedia*))
             (categories
              . ,(list-to-array
                  (mapcar
                   #'(lambda (v) (wiki-article-revision-category-category v))
                   (retrieve-dao 'wiki-article-revision-category :revision
				 revision)))))))
        "{\"content\":\"\", \"categories\": []}")))

(my-defroute :post "/api/wiki/:title" (:admin :user) (title |summary| |html| _parsed) "text/html"
  (dbi:with-transaction *connection*
    (let* ((article (find-dao 'wiki-article :title title))
           (categories (cdr (assoc "categories" _parsed :test #'string=))))
      (if (not article)
          (setf article (create-dao 'wiki-article :title title)))
      (let ((revision
             (create-dao 'wiki-article-revision :article article :author user
			 :summary |summary| :content |html|)))
	(loop for category in categories do
             (create-dao 'wiki-article-revision-category :revision revision :category (first category))))
      nil)))

(my-defroute :post "/api/quiz/create" (:admin :user) nil "text/html"
  (format nil "~a" (object-id (create-dao 'quiz :creator user))))

(my-defroute :post "/api/quiz/:the-quiz-id" (:admin :user) (the-quiz-id |data|) "text/html"
  (let* ((quiz-id (parse-integer the-quiz-id)))
    (format nil "~a"
            (object-id
             (create-dao 'quiz-revision :quiz (find-dao 'quiz :id quiz-id)
			 :content |data| :author user)))))

(my-defroute :get "/api/quiz/:the-id" (:admin :user) (the-id) "application/json"
  (let* ((quiz-id (parse-integer the-id))
         (revision
          (select-dao 'quiz-revision
            (where (:= :quiz (find-dao 'quiz :id quiz-id)))
            (order-by (:desc :id)) (limit 1))))
    (quiz-revision-content (car revision))))

(my-defroute :get "/api/history/:title" (:admin :user) (title) "application/json"
  (let* ((article (find-dao 'wiki-article :title title)))
    (if article
        (encode-json-to-string
         (mapcar
          #'(lambda (r)
              `((id . ,(object-id r))
                (user . ,(user-name (wiki-article-revision-author r)))
                (summary . ,(wiki-article-revision-summary r))
                (created
                 . ,(local-time:format-timestring nil (object-created-at r)))
                (size . ,(length (wiki-article-revision-content r)))))
          (select-dao 'wiki-article-revision (where (:= :article article))
		      (order-by (:desc :created-at)))))
        (throw-code 404))))

(my-defroute :get "/api/search/:query" (:admin :user :anonymous) (query) "application/json"
  (let* ((searchquery (tsquery-convert query))
         (query
          (dbi.driver:prepare *connection*
                              "SELECT a.title, ts_rank_cd((setweight(to_tsvector(a.title), 'A') || setweight(to_tsvector((SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1)), 'D')), query) AS rank, ts_headline(a.title || (SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1), to_tsquery(?)) FROM wiki_article AS A, to_tsquery(?) query WHERE query @@ (setweight(to_tsvector(a.title), 'A') || setweight(to_tsvector((SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1)), 'D')) ORDER BY rank DESC;"))
         (result (dbi.driver:execute query searchquery searchquery)))
    (encode-json-to-string
     (mapcar
      #'(lambda (r)
          `((title . ,(getf r :|title|)) (rank . ,(getf r :|rank|))
            (summary . ,(getf r :|ts_headline|))))
      (dbi.driver:fetch-all result)))))

(my-defroute :get "/api/articles" (:admin :user :anonymous) () "application/json"
  (let* ((articles (select-dao 'wiki-article)))
    (encode-json-to-string (mapcar 'wiki-article-title articles))))

(my-defroute :post "/api/upload" (:admin :user) (|file|) "text/html"
  (let* ((filecontents (nth 0 |file|))
         (filehash
          (byte-array-to-hex-string (digest-stream :sha512 filecontents)))
         (newpath
          (merge-pathnames (concatenate 'string "uploads/" filehash)
                           *application-root*)))
    (with-open-file
        (stream newpath :direction :output :if-exists :supersede :element-type
		'(unsigned-byte 8))
      (write-sequence (slot-value filecontents 'vector) stream))
    filehash))

(my-defroute :post "/api/login" nil (|username| |password|) "text/html"
  (format t "~A ~A~%" |username| |password|)
  (let* ((user (find-dao 'user :name |username|)))
    (if (and user (verify |password| (user-hash user)))
        (progn (setf (gethash :user *session*) (object-id user)) nil)
        (throw-code 403))))

(my-defroute :post "/api/logout" (:admin :user :anonymous) () "text/html"
  (setf (gethash :user *session*) nil)
  nil)

(defun my-quit () (uiop:quit))

(my-defroute :get "/api/killswitch" nil nil "text/html" (my-quit))

(defun starts-with-p (str1 str2)
  "Determine whether `str1` starts with `str2`"
  (let ((p (search str2 str1)))
    (and p (= 0 p))))

(defun get-safe-mime-type (file)
  (let ((mime-type (trivial-mimes:mime file)))
    (if (or (starts-with-p mime-type "image/")
            (starts-with-p mime-type "font/") (equal mime-type "text/css")
            (equal mime-type "application/javascript"))
        mime-type
        (progn (format t "Forbidden mime-type: ~a~%" mime-type) "text/plain"))))

(my-defroute :get "/api/file/:name" (:admin :user :anonymous) (name)
    (get-safe-mime-type (merge-pathnames (concatenate 'string "uploads/" name)))
  (merge-pathnames (concatenate 'string "uploads/" name)))

(defroute ("/js/*" :method :get) (&key splat)
  (basic-headers)
  (setf (getf (response-headers *response*) :content-type)
        "application/javascript")
  (with-cache
      (read-file-into-string
       (merge-pathnames (concatenate 'string "js/" (first splat))
			*application-root*))
    (file-js-gen
     (concatenate 'string (namestring *application-root*) "js/" (first splat)))))

(my-defroute :get "/sw.lisp" nil nil "application/javascript"
  (with-cache
      (read-file-into-string (merge-pathnames "js/sw.lisp" *application-root*))
    (file-js-gen
     (concatenate 'string (namestring *application-root*) "js/sw.lisp"))))

(my-defroute :post "/api/tags" (:admin :user) (_parsed) "application/json"
  (let* ((tags (cdr (assoc "tags" _parsed :test #'string=)))
         (result
          (retrieve-by-sql
           (select (:revision_id (:count :*))
             (from :wiki_article_revision_category) (where (:in :category tags))
             (group-by :revision_id)))))
    (encode-json-to-string
     (loop for revision in result
        when (= (getf revision :count) (length tags))
        collect (wiki-article-title
                 (wiki-article-revision-article
                  (find-dao 'wiki-article-revision :id
			    (getf revision :revision-id))))))))

(my-defroute :post "/api/push-subscription" (:admin :user) (|subscription|) "application/json"
  (let* ((alist (decode-json-from-string |subscription|))
	 (endpoint (cdr (assoc :endpoint alist)))
	 (p256dh (cdr (assoc :p-256-dh (cdr (assoc :keys alist)))))
	 (auth (cdr (assoc :auth (cdr (assoc :keys alist))))))
    (when (and endpoint auth p256dh)
      (dbi:with-transaction *connection*
	(delete-by-values 'web-push :user user :endpoint endpoint :auth auth :p256dh p256dh)
	(create-dao 'web-push :user user :endpoint endpoint :auth auth :p256dh p256dh))
      (send-push p256dh auth endpoint (namestring (asdf:system-relative-pathname :spickipedia #p"../rust-web-push/private.pem")) "Es funktioniert!"))))

(my-defroute :get "/api/substitutions" (:admin :user) () "application/json"
  (bt:with-lock-held (*lock*)
    (encode-json-to-string *VSS*)))

(defparameter *VSS* (make-instance 'spickipedia.vertretungsplan:substitution-schedules))
(defvar *lock* (bt:make-lock))

(defun update-substitution-schedule ()
  (loop for file in (uiop:directory-files "/home/moritz/wiki/vs/") do
     ;;(format t "~%~a~%" file)
       (spickipedia.vertretungsplan:update *VSS* (spickipedia.vertretungsplan:parse-vertretungsplan (spickipedia.pdf:parse file))))
  
  (let ((top-level *standard-output*))
    (bt:make-thread
     (lambda ()
       (loop
	  (log:info "Updating substitution schedule")

	  (handler-case
	      (let ((substitution-schedule (spickipedia.vertretungsplan:parse-vertretungsplan (spickipedia.pdf:parse (spickipedia.vertretungsplan:get-schedule "http://aesgb.de/_downloads/pws/vs.pdf")))))
		(bt:with-lock-held (*lock*)
		  (spickipedia.vertretungsplan:update *VSS* substitution-schedule)))
	    (error (c)
	      (trivial-backtrace:print-backtrace c)
	      (log:error c)))

	  (handler-case
	      (let ((substitution-schedule (spickipedia.vertretungsplan:parse-vertretungsplan (spickipedia.pdf:parse (spickipedia.vertretungsplan:get-schedule "http://aesgb.de/_downloads/pws/vs1.pdf")))))
		(bt:with-lock-held (*lock*)
		  (spickipedia.vertretungsplan:update *VSS* substitution-schedule)))
	    (error (c)
	      (trivial-backtrace:print-backtrace c)
	      (log:error c)))
	  
	  (sleep 60))))))
