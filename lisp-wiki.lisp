
(defpackage :lisp-wiki
  (:use :common-lisp :hunchentoot :mito :sxql :sanitize :ironclad :cl-fad :cl-base64 :bcrypt)
  (:export))

(in-package :lisp-wiki)

(defparameter *default-cost* 13
  "The default value for the COST parameter to HASH.")

(define-sanitize-mode *sanitize-spickipedia*
    :elements ("h1" "h2" "h3" "h4" "h5" "h6" "p" "strike" "sub" "b" "u" "i" "sup" "table" "tbody" "tr" "td" "ul" "a" "br" "ol" "li" "img" "iframe" "span")
    
    :attributes (("h1"          . ("align" "style"))
		 ("span"        . ("class"))
		 ("h2"          . ("align" "style"))
		 ("h3"          . ("align" "style"))
		 ("h4"          . ("align" "style"))
		 ("h5"          . ("align" "style"))
		 ("h6"          . ("align" "style"))
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
		     ("width")
		     ("height")
		     ("vertical-align")
		     ("top")
		     ("margin-right")))


(defparameter *CATCH-ERRORS-P* nil) ;; TODO scan with this line enabled to find bugs
(defparameter *rewrite-for-session-urls* nil)
(defparameter *content-types-for-url-rewrite* nil)
(defparameter *session-secret* "9CU0JB0R12") ;; TODO remove this in production

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

(defclass my-session ()
  ((session-cookie :col-type (:varchar 512)
		   :initarg :session-cookie
		   :accessor my-session-cookie)
   (csrf-token     :col-type (:varchar 512)
		   :initarg :csrf-token
		   :accessor my-session-csrf-token)
   (user           :col-type (or user :null)
		   :initarg  :user
		   :accessor my-session-user))
  (:metaclass mito:dao-table-class))

(defmethod session-verify ((request request))
  (let ((session-identifier (cookie-in (session-cookie-name *acceptor*) request)))
    (if session-identifier
	(mito:find-dao 'my-session :session-cookie session-identifier)
	nil)))

(defmethod session-cookie-value ((my-session my-session))
  (and my-session (my-session-cookie my-session)))

(defun start-my-session ()
  "Returns the current SESSION object. If there is no current session,
creates one and updates the corresponding data structures. In this
case the function will also send a session cookie to the browser."
  (let ((session (session *request*)))
    (when session
      (return-from start-my-session session))
    (setf session (mito:create-dao 'my-session :session-cookie (random-base64) :csrf-token (random-base64))
	  (session *request*) session)
    (set-cookie (session-cookie-name *acceptor*)
                :value (my-session-cookie session)
                :path "/"
                :http-only t)
    (set-cookie "CSRF_TOKEN" :value (my-session-csrf-token session) :path "/")
    (session-created *acceptor* session)
    (setq *session* session)))

(defun regenerate-session (session)
  "Regenerates the cookie value. This should be used
when a user logs in according to the application to prevent against
session fixation attacks. The cookie value being dependent on ID,
USER-AGENT, REMOTE-ADDR, START, and *SESSION-SECRET*, the only value
we can change is START to regenerate a new value. Since we're
generating a new cookie, it makes sense to have the session being
restarted, in time. That said, because of this fact, calling this
function twice in the same second will regenerate twice the same value."
  (setf (my-session-cookie *SESSION*) (random-base64))
  (setf (my-session-csrf-token *SESSION*) (random-base64))
  (mito:save-dao *SESSION*)
  (set-cookie (session-cookie-name *acceptor*)
              :value (my-session-cookie session)
              :path "/"
              :http-only t)
  (set-cookie "CSRF_TOKEN" :value (my-session-csrf-token session) :path "/"))

(setf mito:*mito-logger-stream* t)

(mito:ensure-table-exists 'user)
(mito:ensure-table-exists 'wiki-article)
(mito:ensure-table-exists 'wiki-article-revision)
(mito:ensure-table-exists 'my-session)
(mito:migrate-table 'user)
(mito:migrate-table 'wiki-article)
(mito:migrate-table 'wiki-article-revision)
(mito:migrate-table 'my-session)

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

(defun valid-csrf () ;; ;; TODO secure string compare
  (string= (my-session-csrf-token *SESSION*) (post-parameter "csrf_token")))

(defmacro with-user (&body body)
  `(let ((user (my-session-user *session*)))
     (if user
	 (progn ,@body)
	 (progn
	   (setf (return-code*) +http-authorization-required+)
	   nil))))

(defmacro defget-noauth (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (basic-headers)
     ,@body))

(defmacro defget-noauth-nosession (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (basic-headers-nosession)
     ,@body))

(defmacro defget-noauth-cache (name &body body)
  `(defun ,name ()
     (basic-headers-nosession)
     (cache-forever)
     (if (header-in* "If-Modified-Since")
	 (progn
	   (setf (return-code*) +http-not-modified+)
	   nil)
	 (progn ,@body))))

(defmacro defget (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (basic-headers)
     (with-user
       ,@body)))

(defmacro defpost-noauth (name &body body)
  `(defun ,name ()
     (basic-headers)
     (if (valid-csrf)
	 (progn ,@body)
	 (progn
	   (start-my-session)
	   (setf (return-code*) +http-forbidden+)
	   (log-message* :ERROR "POTENTIAL ONGOING CROSS SITE REQUEST FORGERY ATTACK!!!")
	   nil))))

(defmacro defpost (name &body body) ;; TODO assert that's really a POST REQUEST
  `(defun ,name ()
     (basic-headers)
     (with-user
       (if (valid-csrf)
	   (progn ,@body)
	   (progn
	     (start-my-session)
	     (setf (return-code*) +http-forbidden+)
	     (log-message* :ERROR (format nil "POTENTIAL ONGOING CROSS SITE REQUEST FORGERY ATTACK!!! username: ~a" (user-name user)))
	     nil)))))

(defun basic-headers-nosession ()
  (setf (header-out "X-Frame-Options") "DENY")
  (setf (header-out "Content-Security-Policy") "default-src 'none'; script-src 'self'; img-src 'self' data: ; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com; frame-ancestors 'none';") ;; TODO the inline css from the whsiwyg editor needs to be replaced - write an own editor sometime
  (setf (header-out "X-XSS-Protection") "1; mode=block")
  (setf (header-out "X-Content-Type-Options") "nosniff")
  (setf (header-out "Referrer-Policy") "no-referrer"))

(defun basic-headers ()
  (if (not *SESSION*)
      (start-my-session))
  (basic-headers-nosession))

(defget-noauth index-html
  (handle-static-file "www/index.html"))

(defget-noauth-nosession favicon-handler
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

(defget-noauth get-session-handler
  nil)

(defpost-noauth login-handler
  (let* ((name (post-parameter "name"))
	 (password (post-parameter "password"))
	 (user (mito:find-dao 'user :name name)))
    (if (and user (password= password (user-hash user)))                        ;; TODO prevent timing attack
	(progn
	  (regenerate-session *SESSION*)
	  (setf (my-session-user *SESSION*) user)
	  (mito:save-dao *SESSION*)
	  nil)
	(progn
	  (setf (return-code*) +http-forbidden+)
	  nil))))

(defpost-noauth logout-handler
  (mito:delete-dao *SESSION*)
  (setf *SESSION* nil))

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
	     (create-prefix-dispatcher "/logout" 'index-html)
	     (create-prefix-dispatcher "/search" 'index-html)
	     (create-prefix-dispatcher "/wiki" 'index-html)
	     (create-prefix-dispatcher "/api/wiki" 'wiki-page)
	     (create-prefix-dispatcher "/api/history" 'wiki-page-history)
	     (create-prefix-dispatcher "/api/upload" 'upload-handler)
	     (create-prefix-dispatcher "/api/file" 'file-handler)
	     (create-prefix-dispatcher "/api/search" 'search-handler)
	     (create-prefix-dispatcher "/api/login" 'login-handler)
	     (create-prefix-dispatcher "/api/logout" 'logout-handler)
	     (create-prefix-dispatcher "/api/get-session" 'get-session-handler)
	     (create-prefix-dispatcher "/s/" 'root-handler)
	     (create-prefix-dispatcher "/webfonts/" 'webfonts-handler)
	     (create-prefix-dispatcher "/favicon.ico" 'favicon-handler))))
