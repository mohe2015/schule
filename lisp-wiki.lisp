
(defpackage :lisp-wiki
  (:use :common-lisp :hunchentoot :mito :sxql :sanitize :ironclad :cl-fad :cl-base64 :bcrypt)
  (:export))

(in-package :lisp-wiki)

(defparameter *default-cost* 13
  "The default value for the COST parameter to HASH.")

(define-sanitize-mode *sanitize-spickipedia*
    :elements ("h1" "h2" "h3" "h4" "h5" "h6" "p" "strike" "sub" "b" "u" "i" "sup" "table" "tbody" "tr" "td" "ul" "a" "br" "ol" "li" "img" "iframe")
    
    :attributes (("h1"          . ("align"))
		 ("a"           . ("href" "target"))
		 ("p"           . ("align" "style"))
		 ("img"         . ("src" "style"))
		 ("table"       . ("class"))
		 ("iframe"      . ("src" "width" "height"))) ;; TODO this needs to be checked correctly

    :protocols (("a"           . (("href" . (:ftp :http :https :mailto :relative))))
                ("img"         . (("src"  . (:http :https :relative))))
		("iframe"      . (("src"  . (:http :https :relative))))) ;; TODO only https ;; TODO better use a regex as it fails to detect the same protocol url //www.youtube.com
    :css-attributes (("text-align" . ("center"))
		     ("float"      . ("left" "right"))
		     ("width")))


(defparameter *CATCH-ERRORS-P* nil) ;; TODO scan with this line enabled to find bugs
(defparameter *rewrite-for-session-urls* nil)

(mito:connect-toplevel :sqlite3 :database-name #P"database.db")

(defclass user ()
  ((name  :col-type (:varchar 64)
	  :initarg :name
	  :accessor user-name)
   (group :col-type (:varchar 64)
	  :initarg :group
	  :accessor user-group)
   (hash  :col-type (:varchar 512)
	  :initarg :hash
	  :accessor user-hash))
  (:metaclass mito:dao-table-class))

(defclass wiki-article ()
  ((title :col-type (:varchar 128)
	  :initarg :title
	  :accessor wiki-article-title))
  (:metaclass mito:dao-table-class))

(defclass wiki-article-revision ()
  ((author :col-type user
	   :initarg :author
	   :accessor wiki-article-revision-author)
   (article :col-type wiki-article
	    :initarg :article
	    :accessor wiki-article-revision-article)
   (summary :col-type (:varchar 256)
	    :initarg :summary
	    :accessor wiki-article-revision-summary)
   (content :col-type (:blob)
	    :initarg :content
	    :accessor wiki-article-revision-content))
  (:metaclass mito:dao-table-class))

(setf mito:*mito-logger-stream* t)

(mito:ensure-table-exists 'user)
(mito:ensure-table-exists 'wiki-article)
(mito:ensure-table-exists 'wiki-article-revision)
(mito:migrate-table 'user)
(mito:migrate-table 'wiki-article)
(mito:migrate-table 'wiki-article-revision)

;; run only once
;(mito:insert-dao (make-instance 'user :name "Moritz Hedtke" :group "admin" :hash (hash "common-lisp")))

;;(stop *acceptor*)

(defvar *acceptor* nil)

(if (not *acceptor*)
    (progn
      (defparameter *acceptor* (make-instance 'easy-acceptor :port 8888))
      (start *acceptor*)))

(defun random-base64 ()
  (usb8-array-to-base64-string (random-data 64)))

(defun cache-forever ()
  (setf (header-out "Cache-Control") "max-age: 31536000"))

(defun get-user ()
  (let ((user-id (session-value 'USER_ID *session*)))
    (if user-id
	(mito:find-dao 'user :id user-id)
	nil)))

(defun valid-csrf () ;; ;; TODO secure string compare
  (string= (session-value 'CSRF_TOKEN) (post-parameter "csrf_token")))

(defmacro with-user (&body body)
  `(let ((user (get-user)))
     (if user
	 (progn ,@body)
	 (progn
	   (setf (return-code*) +http-authorization-required+)
	   nil))))

(defmacro defget-noauth (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (basic-headers)
     ,@body))

(defmacro defget-noauth-cache (name &body body)
  `(defun ,name ()
     (cache-forever)
     (basic-headers)
     ,@body))

(defmacro defget (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (with-user
       (basic-headers)
       ,@body)))

(defmacro defpost-noauth (name &body body)
  `(defun ,name ()
     (basic-headers)
     (if (valid-csrf)
	 (progn ,@body)
	 (progn
	   (setf (return-code*) +http-forbidden+)
	   (log-message* :ERROR "POTENTIAL ONGOING CROSS SITE REQUEST FORGERY ATTACK!!!")
	   nil))))

(defmacro defpost (name &body body) ;; TODO assert that's really a POST REQUEST
  `(defun ,name ()
     (with-user ;; HOW should the request be resent when user auth fails with a post request?? 
       (basic-headers)
       (if (valid-csrf)
	   (progn ,@body)
	   (progn
	     (setf (return-code*) +http-forbidden+)
	     (log-message* :ERROR (format nil "POTENTIAL ONGOING CROSS SITE REQUEST FORGERY ATTACK!!! username: ~a" (user-name user)))
	     nil)))))

(defun basic-headers ()
  (if (not (session-value 'CSRF_TOKEN (start-session)))
      (progn
	(setf (session-value 'CSRF_TOKEN) (random-base64))
	(set-cookie "CSRF_TOKEN" :value (session-value 'CSRF_TOKEN) :path "/")))
  (setf (header-out "X-Frame-Options") "DENY")
  (setf (header-out "Content-Security-Policy") "default-src 'none'; script-src 'self'; img-src 'self' data: ; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com") ;; TODO the inline css from the whsiwyg editor needs to be replaced - write an own editor sometime
  (setf (header-out "X-XSS-Protection") "1; mode=block")
  (setf (header-out "X-Content-Type-Options") "nosniff"))

(defget-noauth index-html
  (handle-static-file "www/index.html"))

(defget-noauth favicon-handler
  (handle-static-file "www/favicon.ico"))

(defun wiki-page ()
  (ecase (request-method* *request*)
    (:GET (get-wiki-page))
    (:POST (post-wiki-page))))

(defget get-wiki-page
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if (not article)
	(progn
	  (setf (return-code* *reply*) 404)
	  (return-from get-wiki-page)))
    (let ((revision (mito:select-dao 'wiki-article-revision (where (:= :article article)) (order-by (:desc :id)) (limit 1))))
      (if (not revision)
	  (progn
	  (setf (return-code* *reply*) 404)
	  (return-from get-wiki-page)))
      (clean (wiki-article-revision-content (car revision)) *sanitize-spickipedia*))))

(defpost post-wiki-page 
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if (not article)
	(setf article (mito:create-dao 'wiki-article :title title)))
    (mito:create-dao 'wiki-article-revision :article article :author user :summary (post-parameter "summary") :content (post-parameter "html" *request*))
    nil))

(defget wiki-page-history
  (setf (content-type*) "text/json")
  (let* ((title (subseq (script-name* *REQUEST*) 13)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(json:encode-json-to-string
	 (mapcar #'(lambda (r) `((user . ,(user-name (wiki-article-revision-author r)))
				 (summary . ,(wiki-article-revision-summary r))
				 (created . ,(local-time:format-timestring nil (mito:object-created-at r)))))
		 (mito:select-dao 'wiki-article-revision (where (:= :article article)) (order-by (:desc :created-at)))))
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))

(defget search-handler
  (setf (content-type*) "text/json")
  (let* ((query (subseq (script-name* *REQUEST*) 12)) (results (mito:select-dao 'wiki-article (where (:like :title (concatenate 'string "%" query "%"))))))
    (json:encode-json-to-string (mapcar #'(lambda (a) (wiki-article-title a)) results))))

(define-easy-handler (root :uri "/") () ;; TODO replace this handler
  (basic-headers)
  (redirect "/wiki/Startseite")) ;; TODO permanent redirect?

(defpost upload-handler
  (let* ((filepath (nth 0 (hunchentoot:post-parameter "file")))
	 ;; (filetype (nth 2 (hunchentoot:post-parameter "file")))
	 (filehash (byte-array-to-hex-string (digest-file :sha512 filepath)))	 ;; TODO whitelist mimetypes TODO verify if mimetype is correct
	 (newpath (merge-pathnames (concatenate 'string "uploads/" filehash) *default-pathname-defaults*)))
	 (print newpath)
	 (copy-file filepath newpath :overwrite t)
	 filehash))

(defpost-noauth login-handler
  (let* ((name (post-parameter "name"))
	 (password (post-parameter "password"))
	 (user (mito:find-dao 'user :name name)))
    (if (and user (password= password (user-hash user)))                        ;; TODO prevent timing attack
	(progn
	  (setf (session-value 'USER_ID) (object-id user))
	  nil)
	(progn
	  (setf (return-code*) +http-forbidden+)
	  nil))))

(defget-noauth-cache file-handler
  (handle-static-file (merge-pathnames (concatenate 'string "uploads/" (subseq (script-name* *REQUEST*) 10)))))

(defget-noauth-cache root-handler
  (let ((request-path (request-pathname *request* "/s/")))
    (when (null request-path)
      (setf (return-code*) +http-forbidden+)
      (abort-request-handler))
    (handle-static-file (merge-pathnames request-path #P"www/s/"))))

(defget-noauth-cache webfonts-handler
  (let ((request-path (request-pathname *request* "/webfonts/")))
    (when (null request-path)
      (setf (return-code*) +http-forbidden+)
      (abort-request-handler))
    (handle-static-file (merge-pathnames request-path #P"www/webfonts/"))))

(setq *dispatch-table*
      (nconc
       (list 'dispatch-easy-handlers
	     (create-prefix-dispatcher "/login" 'index-html)
	     (create-prefix-dispatcher "/search" 'index-html)
	     (create-prefix-dispatcher "/wiki" 'index-html)
	     (create-prefix-dispatcher "/api/wiki" 'wiki-page)
	     (create-prefix-dispatcher "/api/history" 'wiki-page-history)
	     (create-prefix-dispatcher "/api/upload" 'upload-handler)
	     (create-prefix-dispatcher "/api/file" 'file-handler)
	     (create-prefix-dispatcher "/api/search" 'search-handler)
	     (create-prefix-dispatcher "/api/login" 'login-handler)
	     (create-prefix-dispatcher "/s/" 'root-handler)
	     (create-prefix-dispatcher "/webfonts/" 'webfonts-handler)
	     (create-prefix-dispatcher "/favicon.ico" 'favicon-handler))))
