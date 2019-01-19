(in-package :cl-user)
(defpackage spickipedia.parenscript
  (:use :cl
	:parenscript)
  (:export :index-js))
(in-package :spickipedia.parenscript)

(defun index-js ()
  (ps-compile-file #P"src/index.lisp"))
