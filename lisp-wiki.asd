(defsystem :lisp-wiki
  :depends-on (:hunchentoot :mito :mito-auth :mito-attachment :cl-json :sanitize :ironclad :cl-fad)
  :components ((:file "lisp-wiki")))
