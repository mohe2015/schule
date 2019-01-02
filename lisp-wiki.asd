(defsystem :lisp-wiki
  :depends-on (:hunchentoot :mito :mito-auth :mito-attachment :cl-json)
  :components ((:file "lisp-wiki")))
