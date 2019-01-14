(defsystem "spickipedia"
  :version "0.1.0"
  :author "Moritz Hedtke"
  :license ""
  :depends-on ("clack"
               "lack"
               "caveman2"
               "envy"
               "cl-ppcre"
               "uiop"

               ;; for @route annotation
               "cl-syntax-annot"

               ;; HTML Template
               "djula"

	       :mito
	       :cl-json
	       :sanitize
	       :ironclad
	       :cl-fad
	       :cl-base64
	       :monkeylib-bcrypt
	       :str
	       )
  :components ((:module "src"
                :components
                (
		 (:file "sanitize")
		 (:file "permissions")
		;; (:file "session")
		 (:file "route")
		 (:file "tsquery-converter")
		 
		 (:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "spickipedia-test"))))
