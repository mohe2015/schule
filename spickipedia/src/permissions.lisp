(in-package :cl-user)
(defpackage spickipedia.permissions
  (:use :cl :mito :spickipedia.db)
  (:export :can))
(in-package :spickipedia.permissions)

(defgeneric action-allowed-p (action group))

;; requirement: user is logged in - but still group may be nil
;; groups: admin, user, nil / other

(defmacro allow-anonymous (handler)
  `(defmethod action-allowed-p ((action (eql ,handler)) group) t))

(allow-any-user 'get-wiki-page)
(allow-any-user 'wiki-page-history)
(allow-any-user 'file-handler)
(allow-any-user 'search-handler)
(allow-any-user 'logout-handler)
(allow-any-user 'article-list-handler)

(defmacro allow-user (handler)
  `(progn
     (defmethod action-allowed-p ((action (eql ,handler)) (group (eql :admin))) t)
     (defmethod action-allowed-p ((action (eql ,handler)) (group (eql :user))) t)
     (defmethod action-allowed-p ((action (eql ,handler)) group) nil)))

(allow-user 'post-wiki-page)
(allow-user 'upload-handler)
(allow-user 'wiki-revision-handler)
(allow-user 'previous-revision-handler)
(allow-user 'create-quiz-handler)
(allow-user 'update-quiz-handler)
(allow-user 'get-quiz-handler)

(defun can (user action)
  (if user
      (action-allowed-p action (user-group user))
      (action-allowed-p action nil)))

