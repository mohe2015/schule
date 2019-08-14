(defpackage spickipedia.argon2
  (:use :cl :cffi :ironclad)
  (:export :hash :verify))

(defpackage spickipedia.sanitize
  (:use :cl :sanitize)
  (:export :*sanitize-spickipedia*))

(defpackage spickipedia.tsquery-converter
  (:use :cl :str)
  (:export :tsquery-convert))

(defpackage spickipedia.parenscript
  (:use :cl :parenscript :ppcre :ironclad)
  (:export :file-js-gen :js-files))

(defpackage spickipedia.config
  (:use :cl)
  (:import-from :envy :config-env-var :defconfig)
  (:export :config
           :*application-root*
           :*static-directory*
           :*template-directory*
           :*database-path*
           :appenv
           :developmentp
           :productionp))

(defpackage spickipedia.db
  (:use :cl :mito)
  (:import-from :spickipedia.config :config)
  (:import-from :cl-dbi :connect-cached)
  (:import-from #:alexandria #:make-keyword #:compose)
  (:export :connection-settings
           :do-generate-migrations
           :do-migrate
           :do-migration-status
           :db
           :with-connection
           :teacher
           :teacher-revision
           :teacher-revision-author
           :teacher-revision-teacher
           :teacher-revision-name
           :teacher-revision-initial
           :course
           :course-revision
           :course-revision-course
           :course-revision-author
           :course-revision-teacher
           :course-revision-type
           :course-revision-subject
           :course-revision-is-tutorial
           :course-revision-grade
           :course-revision-topic
           :user
           :user-grade
           :wiki-article
           :wiki-article-revision
           :my-session
           :quiz
           :quiz-revision
           :user-name
           :user-group
           :user-hash
           :wiki-article-title
           :wiki-article-revision-author
           :wiki-article-revision-article
           :wiki-article-revision-summary
           :wiki-article-revision-content
           :my-session-cookie
           :my-session-csrf-token
           :my-session-user
           :quiz-revision-author
           :quiz-revision-quiz
           :quiz-revision-content
           :wiki-article-revision-category
           :wiki-article-revision-category-revision
           :wiki-article-revision-category-category
           :schedule
           :schedule-grade
           :schedule-revision
           :schedule-revision-author
           :schedule-revision-schedule
           :schedule-data
           :schedule-data-schedule-revision
           :schedule-data-weekday
           :schedule-data-hour
           :schedule-data-week-modulo
           :schedule-data-course
           :schedule-data-room
           :student-course
           :student-course-student
           :student-course-course
	   :web-push
	   :web-push-user
	   :web-push-p256dh
	   :web-push-auth
	   :web-push-endpoint
           :setup-db))

(defpackage spickipedia.web
  (:use :cl
        :caveman2
        :spickipedia.config
        :spickipedia.db
        :spickipedia.sanitize
        :spickipedia.tsquery-converter
        :spickipedia.parenscript
        :mito
        :sxql
        :json
        :sxql.sql-type
        :ironclad
        :sanitize
        :spickipedia.argon2
        :alexandria
        :cl-who
        :cl-fad
        :cl-base64
        :cffi)
  (:shadowing-import-from :ironclad :xor)
  (:shadowing-import-from :cl-fad :copy-file)
  (:shadowing-import-from :cl-fad :copy-stream)
  (:export :*web* :schedule-tab :my-defroute :update-substitution-schedule))
