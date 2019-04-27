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

(defun setup-db ()
  (with-connection (db)
    (ensure-table-exists 'user)
    (ensure-table-exists 'wiki-article)
    (ensure-table-exists 'wiki-article-revision)
    (ensure-table-exists 'my-session)
    (ensure-table-exists 'quiz)
    (ensure-table-exists 'quiz-revision)
    (ensure-table-exists 'wiki-article-revision-category)
    (ensure-table-exists 'teacher)
    (ensure-table-exists 'teacher-revision)
    (migrate-table 'user)
    (migrate-table 'wiki-article)
    (migrate-table 'wiki-article-revision)
    (migrate-table 'my-session)
    (migrate-table 'quiz)
    (migrate-table 'quiz-revision)
    (migrate-table 'wiki-article-revision-category)
    (migrate-table 'teacher)
    (migrate-table 'teacher-revision)))

(setup-db)
