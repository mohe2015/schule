(defsystem :lisp-wiki
  :depends-on (:hunchentoot :mito :mito-attachment :cl-json :sanitize :ironclad :cl-fad :cl-base64)
  :components ((:file "lisp-wiki")))
