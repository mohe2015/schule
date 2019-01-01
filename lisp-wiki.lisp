(defpackage :lisp-wiki
  (:use :common-lisp :cl-who :hunchentoot :parenscript :mito :mito-attachment :mito-auth :can)
  (:shadowing-import-from :mito-attachment :content-type)
  (:export))

(in-package :lisp-wiki)


(mito:connect-toplevel :sqlite3 :database-name #P"/usr/share/nginx/html/database.db")

(deftable user (has-secure-password)
  ((name :col-type (:varchar 60))))

(deftable wiki-article ()
  ((title :col-type (:varchar 128))))

(deftable wiki-article-revision ()
  ((user :col-type user)
   (wiki-article :col-type wiki-article)
   (content :col-type (:blob))))


(setf mito:*mito-logger-stream* t)

(ensure-table-exists 'user)
(ensure-table-exists 'wiki-article)
(ensure-table-exists 'wiki-article-revision)
(migrate-table 'user)
(migrate-table 'wiki-article)
(migrate-table 'wiki-article-revision)

;; (create-dao 'wiki-article :title "Startseite")
;;  (create-dao 'wiki-article-revision :author *user* :article (find-dao 'wiki-article :title "Startseite") :content "THIS IS THE INITIAL CONTENT")


(mito:create-dao 'user :name "Moritz Hedtke" :password "common-lisp")

(defparameter *user* (mito:find-dao 'user :name "Moritz Hedtke"))

(assert (auth *user* "common-lisp"))

(assert (not (auth *user* "wrong-password")))

;;(stop *acceptor*)

(defvar *acceptor* nil)

(if (not *acceptor*)
    (progn
      (defparameter *acceptor* (make-instance 'easy-acceptor :port 8080 :document-root #p"/usr/share/nginx/html/www/"))
      (start *acceptor*)))

(define-easy-handler (api :uri "/api") ()
  (setf (content-type*) "text/html")
  "test")

(push (create-prefix-dispatcher "/api/wiki" 'wiki-page) *dispatch-table*)

(defun wiki-page ()
  (SETF (header-out "X-LOL" *REPLY*) "TEST")
  
  (script-name* *REQUEST*))
