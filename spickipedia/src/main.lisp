(in-package :cl-user)
(defpackage spickipedia
  (:use :cl)
  (:import-from :spickipedia.config
                :config)
  (:import-from :clack
                :clackup)
  (:export :start
           :stop
           :development))
(in-package :spickipedia)

(defvar *appfile-path*
  (asdf:system-relative-pathname :spickipedia #P"app.lisp"))

(defvar *handler* nil)

(defun start ()
  (when *handler*
    (restart-case (error "Server is already running.")
      (restart-server ()
        :report "Restart the server"
        (stop))))
  (setf *handler*
        (clackup *appfile-path* :server :fcgi)))

(defun stop ()
  (prog1
      (clack:stop *handler*)
    (setf *handler* nil)))

(defun development ()
  (let ((top-level *standard-output*))
    (bt:make-thread
      (lambda ()
        (format top-level "Hello from thread!")
        (cl-inotify:with-inotify (inotify T ("." '(:modify)))
          (cl-inotify:do-events (event inotify :blocking-p T)
            (format top-level "Got an update!")
            (asdf:load-system :spickipedia :verbose t)))))))
