(in-package :cl-user)
(defpackage spickipedia.parenscript
  (:use :cl :parenscript)
  (:export :index-js-gen))
(in-package :spickipedia.parenscript)

(defun index-js-gen ()
  (in-package :spickipedia.parenscript)
  (let ((content (ps-compile-file #P"src/index.lisp")))
    (in-package :common-lisp-user)
    content))
