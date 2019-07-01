(defpackage spickipedia.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
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
  (:import-from :spickipedia.config
                :config)
  (:import-from :cl-dbi
                :connect-cached)
  (:import-from #:alexandria
                #:make-keyword
                #:compose)
  (:export :connection-settings
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
           :course-revision-class
           :course-revision-topic
           :user
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
        :bcrypt
        :alexandria
        :cl-who
        :cl-fad
        :cl-base64)
  (:shadowing-import-from :ironclad :xor)
  (:shadowing-import-from :cl-fad :copy-file)
  (:shadowing-import-from :cl-fad :copy-stream)
  (:export :*web* :schedule-tab))
