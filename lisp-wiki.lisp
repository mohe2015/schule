(defpackage :lisp-wiki
  (:use :common-lisp :hunchentoot :mito :mito-auth :sxql)
  (:export))

(in-package :lisp-wiki)

(defparameter *CATCH-ERRORS-P* nil)

(mito:connect-toplevel :sqlite3 :database-name #P"/tmp/b.db")

(defclass user (mito-auth:has-secure-password)
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

(defvar *user* (mito:find-dao 'user :name "Moritz Hedtke"))

;(defvar *article* (make-instance 'wiki-article :title "Startseite"))
;(defvar *user* (make-instance 'user :name "Moritz Hedtke" :group "admin" :password "common-lisp"))
;(mito:insert-dao *article*)
;(mito:insert-dao *user*)

;(defvar *revision* (make-instance 'wiki-article-revision :author *user* :article *article* :content "hi dudes"))
;(mito:insert-dao *revision*)

;(assert (auth *user* "common-lisp"))

;(assert (not (auth *user* "wrong-password")))

;;(stop *acceptor*)

(defvar *acceptor* nil)

(if (not *acceptor*)
    (progn
      (defparameter *acceptor* (make-instance 'easy-acceptor :port 8080 :document-root #p"/usr/share/nginx/html/www/"))
      (start *acceptor*)))

(defparameter *dispatch-table ())

(define-easy-handler (api :uri "/api") ()
  (setf (content-type*) "text/html")
  "test")

(push (create-prefix-dispatcher "/api/wiki" 'wiki-page) *dispatch-table*)

(defun wiki-page ()
  (ecase (request-method* *request*)
    (:GET (get-wiki-page))
    (:POST (post-wiki-page))))

(defun get-wiki-page ()
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(wiki-article-revision-content (car (mito:select-dao 'wiki-article-revision
	     (where (:= :article *article*))
	     (order-by (:desc :id))
	     (limit 1))))
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))

(defun post-wiki-page ()
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(progn
	  (mito:create-dao 'wiki-article-revision :article article :author *user* :content (post-parameter "html" *request*))
	  nil)
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))
