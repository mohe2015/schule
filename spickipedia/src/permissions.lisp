(in-package :cl-user)
(defpackage spickipedia.permissions
  (:use :cl :mito :spickipedia.db :caveman2)
  (:export :with-group))
(in-package :spickipedia.permissions)
