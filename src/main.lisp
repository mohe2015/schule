(in-package :cl-user)

(defpackage schule
  (:use :cl :cl-fsnotify :cl-fad)
  (:import-from :schule.config :config)
  (:import-from :clack :clackup)
  (:export :start :stop :development))

(in-package :schule)

(defvar *appfile-path*
  (asdf/system:system-relative-pathname :schule #P"app.lisp"))

(defvar *handler* nil)

(defun start (&optional (debug nil))
  ;;(unless *handler*
    ;;(schule.web:update-substitution-schedule))
  (mito:connect-toplevel :sqlite3 :database-name (asdf/system:system-relative-pathname :schule #P"spickipedia.db"))
  (when *handler*
    (restart-case (error "Server is already running.")
      (restart-server nil :report "Restart the server" (stop))))
  (setf *handler* (clackup *appfile-path* :server :fcgi :debug debug)))

(defun stop () (prog1 (clack.handler:stop *handler*) (setf *handler* nil)))

(defun mapc-directory-tree (fn directory &key (depth-first-p t))
  (dolist (entry (list-directory directory))
    (unless depth-first-p (funcall fn entry))
    (when (directory-pathname-p entry) (mapc-directory-tree fn entry))
    (when depth-first-p (funcall fn entry))))

(defun development ()
  (start t)
  (let ((top-level *standard-output*))
    (bordeaux-threads:make-thread
     (lambda ()
       (format top-level "Started compilation thread!~%")
       (open-fsnotify)
       (mapc-directory-tree
         (lambda (x)
           (if (not (pathname-name x))
               (add-watch x)))
         (asdf/system:system-source-directory :schule))
       (loop while t do
         (if (get-events)
             (progn
               (format top-level "Got a code update!~%")
               (handler-case (asdf/operate:load-system :schule :force t)
                             (error nil (format top-level "Failed compiling!~%"))))
             (sleep 1)))))))
