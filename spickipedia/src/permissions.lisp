(in-package :cl-user)
(defpackage spickipedia.permissions
  (:use :cl :mito :spickipedia.db :caveman2)
  (:export :with-group))
(in-package :spickipedia.permissions)

(defmacro with-group (groups &body body)
  `(if (member (user-group user) ,groups)
       (progn
	 ,@body)
       (throw-code 403)))
