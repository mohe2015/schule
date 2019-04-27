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
           :parenscript
           :lack
           :lack-middleware-csrf
           :trivial-mimes
           :postmodern
           :cl-who)
  :components
    ((:module "src" :components (
         (:file "sanitize")
         (:file "parenscript")
         (:file "tsquery-converter")
         (:file "main" :depends-on ("config" "view" "db" "web"))
         (:file "web" :depends-on ("view" "parenscript"))
         (:file "schedule" :depends-on ("web"))
         (:file "view" :depends-on ("config"))
         (:file "db" :depends-on ("config"))
         (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "spickipedia-test"))))
