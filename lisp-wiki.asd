(defsystem :lisp-wiki
  :depends-on (:hunchentoot :mito :mito-auth :mito-attachment :cl-json :sanitize)
  :components ((:file "lisp-wiki")))
