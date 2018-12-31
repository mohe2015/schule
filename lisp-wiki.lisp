(defpackage :lisp-wiki
  (:use :common-lisp :cl-who :hunchentoot :parenscript :mito :mito-attachment :mito-auth :can)
  (:shadowing-import-from :mito-attachment :content-type)
  (:export))

(in-package :lisp-wiki)
; (stop *acceptor*)

(if (not *acceptor*)
    (progn
      (defparameter *acceptor* (make-instance 'easy-acceptor :port 8080 :document-root #p"/usr/share/nginx/html/www/"))
      (start *acceptor*)))
