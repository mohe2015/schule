(defsystem :lisp-wiki
  :depends-on (:hunchentoot :mito :cl-json :sanitize :ironclad :cl-fad :cl-base64 :monkeylib-bcrypt)
  :pathname "src/"
  :components ((:file "package")
	       (:file "sanitize" :depends-on ("package"))
	       (:file "database" :depends-on ("package"))
	       (:file "permissions" :depends-on ("package"))
	       (:file "session" :depends-on ("package"))
	       (:file "route" :depends-on ("package"))
	       (:file "lisp-wiki" :depends-on ("sanitize" "database" "permissions" "session" "route"))))
