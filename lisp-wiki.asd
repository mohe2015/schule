(defsystem :lisp-wiki
  :depends-on (:hunchentoot :mito :cl-json :sanitize :ironclad :cl-fad :cl-base64 :monkeylib-bcrypt)
  :components ((:file "lisp-wiki")))
