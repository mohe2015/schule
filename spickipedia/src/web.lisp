(in-package :spickipedia.web)

(declaim (optimize (debug 3)))

(defparameter *default-cost* 13
  "The default value for the COST parameter to HASH.")

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

(defmacro with-user (&body body)
  `(if (gethash :user *SESSION*)
       (let ((user (mito:find-dao 'user :id (gethash :user *SESSION*))))
         ,@body)
       (throw-code 401)))

(defun random-base64 ()
  (usb8-array-to-base64-string (random-data 64)))

(defmacro with-group (groups &body body)
  `(if (member (user-group user) ,groups)
       (progn
         ,@body)
       (throw-code 403)))

(defparameter *VERSION* "1")

(defun valid-csrf () ;; TODO secure string compare
  (string= (my-session-csrf-token *SESSION*) (assoc "csrf_token" (lack.request:request-query-parameters ningle:*request*))))

(defun hash-contents (content)
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence
    :sha256
    (ironclad:ascii-string-to-byte-array content))))

(defun hash-contents-vector (content)
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence
    :sha256
    content)))

(defun cache ()
  (setf (getf (response-headers *response*) :cache-control) "public, max-age=0") ;; one hour ;; TODO change on release
  (setf (getf (response-headers *response*) :vary) "Accept-Encoding"))

(defun cache-forever ()
  (setf (getf (response-headers *response*) :cache-control) "max-age=31556926")
  (setf (getf (response-headers *response*) :vary) "Accept-Encoding")
  (setf (getf (response-headers *response*) :etag) *VERSION*)) ;; TODO fix this dirty implementation

(defmacro with-cache-forever (&body body)
  `(progn
     (cache-forever)
     (if (equal (gethash "if-none-match" (request-headers *request*)) *VERSION*)
         (throw-code 304)
         (progn
           ,@body))))

(defmacro with-cache (key &body body)
  `(progn
     (cache)
     (let* ((key-hash (hash-contents ,key)))
       (if (equal (gethash "if-none-match" (request-headers *request*)) (concatenate 'string "W/\"" key-hash "\""))
           (throw-code 304)
           (progn
             (setf (getf (response-headers *response*) :etag) (concatenate 'string "W/\"" key-hash "\""))
             (progn ,@body))))))

(defmacro with-cache-vector (key &body body)
  `(progn
     (cache)
     (let* ((key-hash (hash-contents-vector ,key)))
       (if (equal (gethash "if-none-match" (request-headers *request*)) (concatenate 'string "W/\"" key-hash "\""))
           (throw-code 304)
           (progn
             (setf (getf (response-headers *response*) :etag) (concatenate 'string "W/\"" key-hash "\""))
             (progn ,@body))))))

(defun basic-headers ()
  (setf (getf (response-headers *response*) :x-frame-options) "DENY")
  (setf (getf (response-headers *response*) :content-security-policy) "default-src 'none'; script-src 'self'; img-src * data: ; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com; frame-ancestors 'none';") ;; TODO the inline css from the whsiwyg editor needs to be replaced - write an own editor sometime ;; WON'T WORK BECAUSE MATH EDITOR ALSO USES IT
  (setf (getf (response-headers *response*) :x-xss-protection) "1; mode=block")
  (setf (getf (response-headers *response*) :x-content-type-options) "nosniff")
  (setf (getf (response-headers *response*) :referrer-policy) "no-referrer"))

(defmacro my-defroute (method path permissions params content-type &body body)
  `(defroute (,path :method ,method) (&key ,@params)
             (basic-headers)
             (setf (getf (response-headers *response*) :content-type) ,content-type)
             (with-connection (db)
               ,(if permissions
                    `(with-user
                         (with-group ',permissions
                           ,@body))
                    `(progn ,@body)))))

(my-defroute :GET "/api/wiki/:title" (:admin :user :anonymous) (title) "application/json"
  (let* ((article (mito:find-dao 'wiki-article :title title)))
    (if (not article)
     (throw-code 404))
    (let ((revision (mito:select-dao 'wiki-article-revision (where (:= :article article)) (order-by (:desc :id)) (limit 1))))
     (if (not revision)
         (throw-code 404))
     (json:encode-json-to-string
      `((content . ,(clean (wiki-article-revision-content (car revision)) *sanitize-spickipedia*))
        (categories . ,(mapcar #'(lambda (v) (wiki-article-revision-category-category v)) (retrieve-dao 'wiki-article-revision-category :revision (car revision)))))))))

(my-defroute :GET "/api/revision/:id" (:admin :user) (id) "application/json"
  (let* ((revision (mito:find-dao 'wiki-article-revision :id (parse-integer id))))
    (if (not revision)
     (throw-code 404))
    (json:encode-json-to-string
     `((content . ,(clean (wiki-article-revision-content revision) *sanitize-spickipedia*))
       (categories . ,(list-to-array (mapcar #'(lambda (v) (wiki-article-revision-category-category v)) (retrieve-dao 'wiki-article-revision-category :revision revision))))))))

(defun list-to-array (list)
  (make-array (length list) :initial-contents list))

;; SELECT article_id FROM wiki_article_revision WHERE id = 8;
;; SELECT id FROM wiki_article_revision WHERE article_id = 1 and id < 8 ORDER BY id DESC LIMIT 1;
;; SELECT id FROM wiki_article_revision WHERE article_id = (SELECT article_id FROM wiki_article_revision WHERE id = 8) and id < 8 ORDER BY id DESC LIMIT 1;
(my-defroute :GET "/api/previous-revision/:the-id" (:admin :user) (the-id) "application/json"
  (let* ((id (parse-integer the-id))
         (query (dbi:prepare *connection* "SELECT id FROM wiki_article_revision WHERE article_id = (SELECT article_id FROM wiki_article_revision WHERE id = ?) and id < ? ORDER BY id DESC LIMIT 1;"))
         (result (dbi:execute query id id))
         (previous-id (getf (dbi:fetch result) :|id|)))
    (if previous-id
     (let ((revision (mito:find-dao 'wiki-article-revision :id previous-id)))
       (json:encode-json-to-string
        `((content . ,(clean (wiki-article-revision-content revision) *sanitize-spickipedia*))
          (categories . ,(list-to-array (mapcar #'(lambda (v) (wiki-article-revision-category-category v)) (retrieve-dao 'wiki-article-revision-category :revision revision)))))))
     "{\"content\":\"\", \"categories\": []}")))

(my-defroute :POST "/api/wiki/:title" (:admin :user) (title |summary| |html| _parsed) "text/html"
  (dbi:with-transaction *connection*
    (let* ((article (mito:find-dao 'wiki-article :title title))
           (categories (cdr (assoc "categories" _parsed :test #'string=))))
      (if (not article)
       (setf article (mito:create-dao 'wiki-article :title title)))
      (let ((revision (mito:create-dao 'wiki-article-revision :article article :author user :summary |summary| :content |html|)))
       (loop for category in categories do
            (mito:create-dao 'wiki-article-revision-category :revision revision :category category)))
      nil)))

(my-defroute :POST "/api/quiz/create" (:admin :user) () "text/html"
  (format nil "~a" (object-id (mito:create-dao 'quiz :creator user))))

(my-defroute :POST "/api/quiz/:the-quiz-id" (:admin :user) (the-quiz-id |data|) "text/html"
         (let* ((quiz-id (parse-integer the-quiz-id)))
           (format nil "~a" (object-id (create-dao 'quiz-revision :quiz (find-dao 'quiz :id quiz-id) :content |data| :author user)))))

(my-defroute :GET "/api/quiz/:the-id" (:admin :user) (the-id)  "application/json"
   (let* ((quiz-id (parse-integer the-id))
          (revision (mito:select-dao 'quiz-revision (where (:= :quiz (find-dao 'quiz :id quiz-id))) (order-by (:desc :id)) (limit 1))))
     (quiz-revision-content (car revision))))


(my-defroute :GET "/api/history/:title" (:admin :user) (title) "application/json"
  (let* ((article (mito:find-dao 'wiki-article :title title)))
    (if article
     (json:encode-json-to-string
      (mapcar #'(lambda (r) `((id   . ,(object-id r))
                              (user . ,(user-name (wiki-article-revision-author r)))
                              (summary . ,(wiki-article-revision-summary r))
                              (created . ,(local-time:format-timestring nil (mito:object-created-at r)))
                              (size    . ,(length (wiki-article-revision-content r)))))
          (mito:select-dao 'wiki-article-revision (where (:= :article article)) (order-by (:desc :created-at)))))
     (throw-code 404))))

(my-defroute :GET "/api/search/:query" (:admin :user :anonymous) (query) "application/json"
 (let* ((searchquery (tsquery-convert query))
        (query (dbi:prepare *connection* "SELECT a.title, ts_rank_cd((setweight(to_tsvector(a.title), 'A') || setweight(to_tsvector((SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1)), 'D')), query) AS rank, ts_headline(a.title || (SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1), to_tsquery(?)) FROM wiki_article AS A, to_tsquery(?) query WHERE query @@ (setweight(to_tsvector(a.title), 'A') || setweight(to_tsvector((SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1)), 'D')) ORDER BY rank DESC;"))
        (result (dbi:execute query searchquery searchquery)))
   (json:encode-json-to-string (mapcar #'(lambda (r) `((title . ,(getf r :|title|))
                                                       (rank  . ,(getf r :|rank|))
                                                       (summary . ,(getf r :|ts_headline|)))) (dbi:fetch-all result)))))

(my-defroute :GET "/api/articles" (:admin :user :anonymous) () "application/json"
  (let* ((articles (mito:select-dao 'wiki-article)))
    (json:encode-json-to-string (mapcar 'wiki-article-title articles))))

(my-defroute :POST "/api/upload" (:admin :user) (|file|) "text/html"
  (let* ((filecontents (nth 0 |file|))
         (filehash (byte-array-to-hex-string (digest-stream :sha512 filecontents)))      ;; TODO whitelist mimetypes TODO verify if mimetype is correct
         (newpath (merge-pathnames (concatenate 'string "uploads/" filehash) *application-root*)))
    ;; (break)
    (with-open-file (stream newpath :direction :output :if-exists :supersede :element-type '(unsigned-byte 8))
     (write-sequence (slot-value filecontents 'vector) stream))
    filehash))

;; noauth
(my-defroute :POST "/api/login" nil (|name| |password|) "text/html"
  (format t "~A ~A~%" |name| |password|)
  (let* ((user (mito:find-dao 'user :name |name|)))
    (if (and user (password= |password| (user-hash user)))                        ;; TODO prevent timing attack
     (progn
       ;;(regenerate-session *SESSION*) ;; TODO this is IMPORTANT WE NEED TO FIX THIS THIS IS IMPORTANT WE NEED TO FIX THIS
       (setf (gethash :user *SESSION*) (object-id user))
       nil)
     (throw-code 403))))

;; noauth
(my-defroute :POST "/api/logout" (:admin :user :anonymous) () "text/html"
  (setf (gethash :user *SESSION*) nil)
  nil)

(defun my-quit ()
  #+sbcl (sb-ext:quit)
  #+clisp (ext:exit)
  #+ccl (ccl:quit)
  #+ecl (ext:quit)
  #+allegro (excl:exit))

;; noauth
(my-defroute :GET "/api/killswitch" nil () "text/html"
  (my-quit))

(defun starts-with-p (str1 str2)
  "Determine whether `str1` starts with `str2`"
  (let ((p (search str2 str1)))
    (and p (= 0 p))))

(defun get-safe-mime-type (file)
  (let ((mime-type (mimes:mime file)))
    (if (or
         (starts-with-p mime-type "image/")
         (starts-with-p mime-type "font/")
         (equal mime-type "text/css")
         (equal mime-type "application/javascript"))
        mime-type
        (progn
          (format t "Forbidden mime-type: ~a~%" mime-type)
          "text/plain"))))

;; noauth cache
(my-defroute :GET "/api/file/:name" (:admin :user :anonymous) (name) (get-safe-mime-type (merge-pathnames (concatenate 'string "uploads/" name)))
  (merge-pathnames (concatenate 'string "uploads/" name)))

(defroute ("/js/*" :method :GET) (&key splat)
  (print (first splat))
  (basic-headers)
  (setf (getf (response-headers *response*) :content-type) "application/javascript")
  (with-cache (read-file-into-string (merge-pathnames (concatenate 'string "js/" (first splat)) *application-root*))
    (file-js-gen (concatenate 'string (namestring *application-root*) "js/" (first splat))))) ;; TODO local file inclusion

;; TODO basically depends on every asset
(my-defroute :GET "/sw.lisp" nil () "application/javascript"
  (with-cache (read-file-into-string (merge-pathnames "js/sw.lisp" *application-root*))
    (file-js-gen (concatenate 'string (namestring *application-root*) "js/sw.lisp"))))

;; TODO implement correctly
(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))

(my-defroute :POST "/api/tags" (:admin :user) (_parsed) "application/json"
  (let* ((tags (cdr (assoc "tags" _parsed :test #'string=)))
         (result (mito:retrieve-by-sql
                  (select
                    (:revision_id (:count :*))
                    (from :wiki_article_revision_category)
                    (where (:in :category tags))
                    (group-by :revision_id)))))
    (json:encode-json-to-string
      (loop for revision in result when (= (getf revision :count) (length tags)) collect
        (wiki-article-title (wiki-article-revision-article (mito:find-dao 'wiki-article-revision :id (getf revision :revision-id))))))))
