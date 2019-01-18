(in-package :cl-user)
(defpackage spickipedia.permissions
  (:use :cl))
(in-package :spickipedia.permissions)

(defgeneric action-allowed-p (action group))

;; requirement: user is logged in - but still group may be nil
;; groups: admin, user, nil / other

;; every user can read wiki pages
(defmethod action-allowed-p ((action (eql 'get-wiki-page)) group) t)

;; every user can see the history
(defmethod action-allowed-p ((action (eql 'wiki-page-history)) group) t)

;; every user can view the files
(defmethod action-allowed-p ((action (eql 'file-handler)) group) t)

;; every user can search
(defmethod action-allowed-p ((action (eql 'search-handler)) group) t)

;; every user can logout
(defmethod action-allowed-p ((action (eql 'logout-handler)) group) t)

;; every user can list all articles
(defmethod action-allowed-p ((action (eql 'article-list-handler)) group) t)

;; only admins and users can edit them
(defmethod action-allowed-p ((action (eql 'post-wiki-page)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'post-wiki-page)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'post-wiki-page)) group) nil)

;; only admins and users can upload images
(defmethod action-allowed-p ((action (eql 'upload-handler)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'upload-handler)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'upload-handler)) group) nil)

;; only admins and users can see revisions
(defmethod action-allowed-p ((action (eql 'wiki-revision-handler)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'wiki-revision-handler)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'wiki-revision-handler)) group) nil)

;; only admins and users can see previous revision
(defmethod action-allowed-p ((action (eql 'previous-revision-handler)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'previous-revision-handler)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'previous-revision-handler)) group) nil)


;; only admins and users can create a quiz
(defmethod action-allowed-p ((action (eql 'create-quiz-handler)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'create-quiz-handler)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'create-quiz-handler)) group) nil)

;; only admins and users can create a quiz question
(defmethod action-allowed-p ((action (eql 'update-quiz-handler)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'update-quiz-handler)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'update-quiz-handler)) group) nil)

;; only admins and users can create a quiz question
(defmethod action-allowed-p ((action (eql 'get-quiz-handler)) (group (eql :admin))) t)
(defmethod action-allowed-p ((action (eql 'get-quiz-handler)) (group (eql :user))) t)
(defmethod action-allowed-p ((action (eql 'get-quiz-handler)) group) nil)

(defun can (user action)
  (if user
      (action-allowed-p action (user-group user))
      (action-allowed-p action nil)))

