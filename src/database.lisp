(in-package :lisp-wiki)

(let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
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

  ;;  (mito:create-dao 'user :name "Anonymous" :hash (hash "xfg3zte94h") :group nil)

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


  (setf mito:*mito-logger-stream* t)

  (mito:ensure-table-exists 'user)
  (mito:ensure-table-exists 'wiki-article)
  (mito:ensure-table-exists 'wiki-article-revision)
  (mito:ensure-table-exists 'my-session)
  (mito:migrate-table 'user)
  (mito:migrate-table 'wiki-article)
  (mito:migrate-table 'wiki-article-revision)
  (mito:migrate-table 'my-session))


;; run only once
;(mito:insert-dao (make-instance 'user :name "Moritz Hedtke" :group "admin" :hash (hash "common-lisp")))
