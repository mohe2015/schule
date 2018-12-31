(defsystem :lisp-wiki
  :depends-on (:cl-who :hunchentoot :parenscript :mito :mito-attachment :mito-auth :can)
  :components ((:file "lisp-wiki")))
