(defpackage :lisp-wiki
  (:use :common-lisp :cl-who :hunchentoot :parenscript)
  (:export))

(in-package :lisp-wiki)
; (stop *acceptor*)

(DEFPARAMETER *acceptor* (make-instance 'easy-acceptor :port 8080 :document-root #p"/usr/share/nginx/html/www/"))
(start *acceptor*)

