(defsystem "spickipedia"
  :version "0.1.0"
  :author "Moritz Hedtke"
  :license ""
  :defsystem-depends-on (:paren-files)
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop
               :cl-fsnotify
	       :fare-mop
               :mito
               :cl-json
               :sanitize
               :ironclad
               :cl-fad
               :cl-base64
               :str
               :parenscript
               :lack
               :lack-middleware-csrf
               :trivial-mimes
               :deflate
               :cl-pdf-parser
               :flexi-streams
	       :queues.simple-queue
	       :cffi
	       :dexador
	       :group-by
	       :log4cl
	       :serapeum
	       :bt-semaphore
	       :trivial-backtrace
               :cl-who)
  :components ;; TODO FIXME fix all dependencies as otherwise there are compilation failures
  ((:module
    "."
    :components
    (
     (:file "src/web-push")
     (:file "src/package" :depends-on ("src/web-push")) ;; TODO split up into the single packages or google how you should do it

     (:file "src/argon2")
     
     (:file "src/html/helpers" :depends-on ("src/package"))
     (:file "src/html/user-courses/index" :depends-on ("src/package" "src/html/helpers"))
     (:file "src/html/contact/index" :depends-on ("src/package" "src/html/helpers"))
     (:file "src/html/settings/index" :depends-on ("src/package" "src/html/helpers"))
     (:file "src/html/schedule/index" :depends-on ("src/package" "src/html/helpers"))
     (:file "src/html/substitution-schedule/index" :depends-on ("src/package" "src/html/helpers"))
     (:file "src/index" :depends-on ("src/package" "src/html/helpers" "src/html/user-courses/index" "src/html/settings/index" "src/html/schedule/index" "src/html/substitution-schedule/index"))
     
     (:file "src/config")
     (:file "src/sanitize" :depends-on ("src/package"))

     (:file "src/parenscript" :depends-on ("src/package"))


     (:parenscript-file "js/utils")
     (:parenscript-file "js/fetch" :depends-on ("js/state-machine" "js/utils" "js/show-tab"))
     (:parenscript-file "js/categories" :depends-on ("js/show-tab" "js/read-cookie" "js/utils" "js/template"))
     (:parenscript-file "js/file-upload" :depends-on ("js/read-cookie" "js/utils"))
     (:parenscript-file "js/wiki/page" :depends-on ("js/template" "js/show-tab" "js/math" "js/image-viewer" "js/fetch" "js/utils" "js/state-machine"))
     (:parenscript-file "js/search" :depends-on ("js/show-tab" "js/utils" "js/template" "js/fetch"))
     (:parenscript-file "js/quiz" :depends-on ("js/utils"))
     (:parenscript-file "js/logout" :depends-on ("js/show-tab" "js/read-cookie" "js/state-machine" "js/utils" "js/fetch"))
     (:parenscript-file "js/login" :depends-on ("js/get-url-parameter" "js/read-cookie" "js/state-machine" "js/show-tab" "js/utils" "js/fetch"))
     (:parenscript-file "js/root" :depends-on ("js/state-machine" "js/utils"))
     (:parenscript-file "js/history" :depends-on ("js/state-machine" "js/show-tab" "js/cleanup" "js/math" "js/fetch" "js/utils" "js/template"))
     (:parenscript-file "js/wiki/page/edit" :depends-on ("js/cleanup" "js/show-tab" "js/math" "js/editor" "js/utils" "js/fetch" "js/template" "js/state-machine"))
     (:parenscript-file "js/create" :depends-on ("js/state-machine" "js/editor" "js/show-tab" "js/utils" "js/state-machine"))
     (:parenscript-file "js/articles" :depends-on ("js/show-tab" "js/utils"))
     (:parenscript-file "js/show-tab" :depends-on ("js/utils"))
     
     (:parenscript-file "js/contact/index" :depends-on ("js/show-tab"))
     (:parenscript-file "js/state-machine" :depends-on ("js/contact/index" "js/wiki/page" "js/search" "js/quiz" "js/logout" "js/login" "js/root" "js/history" "js/wiki/page/edit" "js/create" "js/articles" "js/show-tab" "js/categories" "js/courses/index" "js/schedule/id" "js/schedules/new" "js/schedules/index" "js/student-courses/index" "js/settings/index" "js/utils" "js/template" "js/cleanup" "js/math" "js/image-viewer" "js/fetch" "js/substitution-schedule/index"))

     (:parenscript-file "js/editor-lib" :depends-on ("js/file-upload" "js/categories" "js/fetch" "js/utils"))			
     (:parenscript-file "js/utils")
     (:parenscript-file "js/index" :depends-on ("js/state-machine" "js/editor-lib" "js/utils"))
     


     (:file "src/tsquery-converter" :depends-on ("src/package"))
     
     (:file "src/web" :depends-on ("src/package" "src/parenscript" "src/db" "src/index" "src/argon2" "src/vertretungsplan" "src/web-push"))
     (:file "src/settings" :depends-on ("src/package" "src/web"))
     (:file "src/schedule" :depends-on ("src/package" "src/web")) ;; TODO FIXME clean up this dependency garbage
     (:file "src/student-courses" :depends-on ("src/package" "src/web"))
     (:file "src/default-handler" :depends-on ("src/package" "src/web"))
     (:file "src/pdf")
     (:file "src/libc")
     (:file "src/vertretungsplan" :depends-on ("src/pdf" "src/libc"))
     
     (:file "src/db" :depends-on ("src/package" "src/config"))
     
     (:file "src/main" :depends-on ("src/package" "src/config" "src/db" "src/web")))))
  :description ""
  :in-order-to ((test-op (test-op "spickipedia-test"))))
