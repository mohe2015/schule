(defsystem "spickipedia"
  :version "0.1.0"
  :author "Moritz Hedtke"
  :license ""
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop
               :cl-inotify
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
               :cl-who)
  :components ;; TODO FIXME fix all dependencies as otherwise there are compilation failures
    ((:module "src" :components (
         (:file "sanitize")
         (:file "parenscript")
         (:file "tsquery-converter")
         (:file "package")
         (:file "html/user-courses/index" :depends-on ("package"))
         (:file "index" :depends-on ("package" "html/user-courses/index"))
         (:file "main" :depends-on ("config" "db" "web" "schedule"))
         (:file "web" :depends-on ("package" "parenscript" "db" "index"))
         (:file "schedule" :depends-on ("package" "web"))
         (:file "db" :depends-on ("package" "config"))
         (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "spickipedia-test"))))
