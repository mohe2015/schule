(in-package :cl-user)
(defpackage spickipedia.db
  (:use :cl)
  (:import-from :spickipedia.config
                :config)
  (:import-from :mito
                :*connection*)
  (:import-from :cl-dbi
                :connect-cached)
  (:import-from #:alexandria
                 #:make-keyword
                #:compose)
  (:export :connection-settings
           :db
           :with-connection
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
	   ))
(in-package :spickipedia.db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))

(with-connection (db)
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
    (:metaclass mito:dao-table-class))

  (defclass wiki-article ()
    ((title :col-type (:varchar 128)
	    :initarg :title
	    :accessor wiki-article-title))
    (:metaclass mito:dao-table-class))

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
     (categories :col-type "text[]"
		 :initarg :categories
		 :accessor wiki-article-revision-categories)
     (content :col-type (:text)
	      :initarg :content
	      :accessor wiki-article-revision-content))
    (:metaclass mito:dao-table-class))

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
    (:metaclass mito:dao-table-class))

  (defclass quiz ()
    ()
    (:metaclass mito:dao-table-class))

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
    (:metaclass mito:dao-table-class))

  (mito:ensure-table-exists 'user)
  (mito:ensure-table-exists 'wiki-article)
  (mito:ensure-table-exists 'wiki-article-revision)
  (mito:ensure-table-exists 'my-session)
  (mito:ensure-table-exists 'quiz)
  (mito:ensure-table-exists 'quiz-revision)
  (mito:ensure-table-exists 'wiki-article-revision-category)
  (mito:migrate-table 'user)
  (mito:migrate-table 'wiki-article)
  (mito:migrate-table 'wiki-article-revision)
  (mito:migrate-table 'my-session)
  (mito:migrate-table 'quiz)
  (mito:migrate-table 'quiz-revision)
  (mito:migrate-table 'wiki-article-revision-category))
