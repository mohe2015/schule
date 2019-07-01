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
         (:file "package") ;; TODO split up into the single packages or google how you should do it
         (:file "sanitize" :depends-on ("package"))
         (:file "parenscript" :depends-on ("package"))
         (:file "tsquery-converter" :depends-on ("package"))
         (:file "html/user-courses/index" :depends-on ("package"))
         (:file "index" :depends-on ("package" "html/user-courses/index"))
         (:file "main" :depends-on ("package" "config" "db" "web"))
         (:file "web" :depends-on ("package" "parenscript" "db" "index"))
         (:file "schedule" :depends-on ("package" "web")) ;; TODO FIXME clean up this dependency garbase
         (:file "student-courses" :depends-on ("package" "web"))
         (:file "default-handler" :depends-on ("package" "web"))
         (:file "db" :depends-on ("package" "config"))
         (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "spickipedia-test"))))
