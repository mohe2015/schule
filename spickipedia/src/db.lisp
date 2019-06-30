(in-package :cl-user)
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

(in-package :spickipedia.db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))

(defclass user ()
  ((name  :col-type (:varchar 64)
    :initarg :name
    :accessor user-name)
   (group :col-type (:varchar 64)
    :initarg :group
    :inflate (compose #'make-keyword #'string-upcase)
         :deflate #'string-downcase
    :accessor user-group)
   (hash  :col-type (:varchar 512)
    :initarg :hash
    :accessor user-hash))
  (:metaclass dao-table-class))

(defclass wiki-article ()
  ((title :col-type (:varchar 128)
    :initarg :title
    :accessor wiki-article-title))
  (:metaclass dao-table-class))

(defclass wiki-article-revision ()
  ((author :col-type user
      :initarg :author
      :accessor wiki-article-revision-author)
   (article :col-type wiki-article
    :initarg :article
    :accessor wiki-article-revision-article)
   (summary :col-type (:varchar 256)
    :initarg :summary
    :accessor wiki-article-revision-summary)
   (content :col-type (:text)
    :initarg :content
    :accessor wiki-article-revision-content))
  (:metaclass dao-table-class))

(defclass wiki-article-revision-category ()
  ((revision :col-type wiki-article-revision
    :initarg :revision
    :accessor wiki-article-revision-category-revision)
   (category :col-type (:varchar 256)
    :initarg :category
    :accessor wiki-article-revision-category-category))
  (:metaclass dao-table-class))

(defclass my-session ()
  ((session-cookie :col-type (:varchar 512)
        :initarg :session-cookie
        :accessor my-session-cookie)
   (csrf-token     :col-type (:varchar 512)
       :initarg :csrf-token
       :accessor my-session-csrf-token)
   (user           :col-type (or user :null)
       :initarg  :user
       :accessor my-session-user))
  (:metaclass dao-table-class))

(defclass quiz ()
  ()
  (:metaclass dao-table-class))

(defclass quiz-revision ()
  ((author :col-type user
      :initarg :author
      :accessor quiz-revision-author)
   (quiz :col-type quiz
    :initarg :quiz
    :accessor quiz-revision-quiz)
   (content :col-type (:text)
    :initarg :content
    :accessor quiz-revision-content))
  (:metaclass dao-table-class))

(defclass teacher ()
  ()
  (:metaclass dao-table-class))

(defclass teacher-revision ()
  ((author :col-type user
           :initarg :author
           :accessor teacher-revision-author)
   (teacher :col-type teacher
            :initarg :teacher
            :accessor teacher-revision-teacher)
   (name :col-type (:varchar 128)
         :initarg :name
         :accessor teacher-revision-name)
   (initial :col-type (:varchar 64)
            :initarg :initial
            :accessor teacher-revision-initial))
  (:metaclass dao-table-class))

(defclass course ()
  ()
  (:metaclass dao-table-class))

(defclass course-revision ()
  ((author :col-type user
           :initarg :author
           :accessor course-revision-author)
   (course :col-type course
     :initarg :course
     :accessor course-revision-course)
   (teacher :col-type teacher
            :initarg :teacher
            :accessor course-revision-teacher)
   (type :col-type (:varchar 4)
         :initarg :type
         :accessor course-revision-type)
   (subject :col-type (:varchar 64)
            :initarg :subject
            :accessor course-revision-subject)
   (is-tutorial :col-type :boolean
                :initarg :is-tutorial
                :accessor course-revision-is-tutorial)
   (class :col-type (:varchar 64)
          :initarg :class
          :accessor course-revision-class)
   (topic :col-type (:varchar 512)
          :initarg :topic
          :accessor course-revision-topic))
  (:metaclass dao-table-class))

(defclass schedule ()
  ((grade :col-type (:varchar 64)
          :initarg :grade
          :accessor schedule-grade))
  (:metaclass dao-table-class))

(defclass schedule-revision ()
  ((author :col-type user
           :initarg :author
           :accessor schedule-revision-author)
   (schedule :col-type schedule
             :initarg :schedule
             :accessor schedule-revision-schedule))
  (:metaclass dao-table-class))

(defclass schedule-data ()
  ((schedule-revision :col-type schedule-revision
                      :initarg :schedule-revision
                      :accessor schedule-data-schedule-revision)
   (weekday :col-type (:integer)
            :initarg :weekday
            :accessor schedule-data-weekday)
   (hour :col-type (:integer)
         :initarg :hour
         :accessor schedule-data-hour)
   (week-modulo :col-type (:integer)
                :integer :week-modulo
                :accessor schedule-data-week-modulo)
   (course :col-type course
           :initarg :course
           :accessor schedule-data-course)
   (room   :col-type (:varchar 32)
           :initarg :room
           :accessor schedule-data-room))
  (:metaclass dao-table-class))

(defun check-table (table)
  (ensure-table-exists table)
  (migrate-table table))

(defun setup-db ()
  (with-connection (db)
    (check-table 'user)
    (check-table 'wiki-article)
    (check-table 'wiki-article-revision)
    (check-table 'my-session)
    (check-table 'quiz)
    (check-table 'quiz-revision)
    (check-table 'wiki-article-revision-category)
    (check-table 'teacher)
    (check-table 'teacher-revision)
    (check-table 'course)
    (check-table 'course-revision)
    (check-table 'schedule)
    (check-table 'schedule-revision)
    (check-table 'schedule-data)))
