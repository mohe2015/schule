
(defpackage :lisp-wiki
  (:use :common-lisp :hunchentoot :mito :sxql :sanitize :ironclad :cl-fad :cl-base64)
  (:export))

(in-package :lisp-wiki)

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

(mito:connect-toplevel :sqlite3 :database-name #P"database.db")

(defclass user ()
  ((name  :col-type (:varchar 64)
	  :initarg :name
	  :accessor user-name)
   (group :col-type (:varchar 64)
	  :initarg :group
	  :accessor user-group))
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
;;(defvar *article* (make-instance 'wiki-article :title "Startseite"))
;;(defvar *user* (make-instance 'user :name "Moritz Hedtke" :group "admin" :password "common-lisp"))
;;(mito:insert-dao *article*)
;;(mito:insert-dao *user*)
;;(defvar *revision* (make-instance 'wiki-article-revision :author *user* :article *article* :content "hi dudes"))
;;(mito:insert-dao *revision*)
;;(assert (auth *user* "common-lisp"))
;;(assert (not (auth *user* "wrong-password")))

(defvar *user* (mito:find-dao 'user))

;;(stop *acceptor*)

(defvar *acceptor* nil)

(if (not *acceptor*)
    (progn
      (defparameter *acceptor* (make-instance 'easy-acceptor :port 8888))
      (start *acceptor*)))

(defun random-base64 ()
  (usb8-array-to-base64-string (random-data 64)))

(defun basic-headers ()
  (setf (header-out "X-Frame-Options") "DENY")
  (setf (header-out "Content-Security-Policy") "default-src 'none'; script-src 'self'; img-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com") ;; TODO the inline css from the whsiwyg editor needs to be replaced - write an own editor sometime
  (setf (header-out "X-XSS-Protection") "1; mode=block")
  (setf (header-out "X-Content-Type-Options") "nosniff"))

(defun wiki-page-html ()
  (basic-headers)
  (handle-static-file "www/index.html"))

(defun wiki-page ()
  (ecase (request-method* *request*)
    (:GET (get-wiki-page))
    (:POST (post-wiki-page))))

(defun get-wiki-page ()
  (basic-headers)
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(clean (wiki-article-revision-content (car (mito:select-dao 'wiki-article-revision
									    (where (:= :article article))
									    (order-by (:desc :id))
									    (limit 1)))) *sanitize-spickipedia*)
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))

(defun post-wiki-page ()
  (basic-headers)
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(progn
	  (mito:create-dao 'wiki-article-revision :article article :author *user* :content (post-parameter "html" *request*))
	  nil)
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))

(defun wiki-page-history ()
  (basic-headers)
  (setf (content-type*) "text/json")
  (let* ((title (subseq (script-name* *REQUEST*) 13)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(json:encode-json-to-string
	 (mapcar #'(lambda (r) `((user . ,(user-name (wiki-article-revision-author r)))
				 (content . ,(wiki-article-revision-content r))
				 (created . ,(local-time:format-timestring nil (mito:object-created-at (wiki-article-revision-author r))))))
		 (mito:retrieve-dao 'wiki-article-revision :article article)))
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))

(define-easy-handler (root :uri "/") ()
  (basic-headers)
  (redirect "/wiki/Startseite"))

(defun upload-handler ()
  (basic-headers)
  (let* ((filepath (nth 0 (hunchentoot:post-parameter "file")))
	 ;; (filetype (nth 2 (hunchentoot:post-parameter "file")))
	 (filehash (byte-array-to-hex-string (digest-file :sha512 filepath)))	 ;; TODO whitelist mimetypes TODO verify if mimetype is correct
	 (newpath (merge-pathnames (concatenate 'string "uploads/" filehash) *default-pathname-defaults*)))
	 (print newpath)
	 (copy-file filepath newpath :overwrite t)
	 filehash))

(defun file-handler ()
  (basic-headers)
  (handle-static-file (merge-pathnames (concatenate 'string "uploads/" (subseq (script-name* *REQUEST*) 10)))))

(defun root-handler ()
  (basic-headers)
  (let ((request-path (request-pathname *request* "/")))
    (when (null request-path)
      (setf (return-code*) +http-forbidden+)
      (abort-request-handler))
    (handle-static-file (merge-pathnames request-path #P"www/"))))

(setq *dispatch-table*
      (nconc
       (list 'dispatch-easy-handlers
	     (create-prefix-dispatcher "/wiki" 'wiki-page-html)
	     (create-prefix-dispatcher "/api/wiki" 'wiki-page)
	     (create-prefix-dispatcher "/api/history" 'wiki-page-history)
	     (create-prefix-dispatcher "/api/upload" 'upload-handler)
	     (create-prefix-dispatcher "/api/file" 'file-handler)
	     (create-prefix-dispatcher "/" 'root-handler))))
