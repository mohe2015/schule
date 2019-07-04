(in-package :cl-user)
(defpackage spickipedia
  (:use :cl :cl-fsnotify)
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

(defun mapc-directory-tree (fn directory &key (depth-first-p t))
  (dolist (entry (cl-fad:list-directory directory))
    (unless depth-first-p
      (funcall fn entry))
    (when (cl-fad:directory-pathname-p entry)
      (mapc-directory-tree fn entry))
    (when depth-first-p
      (funcall fn entry))))

(defun development ()
  (start)
  (let ((top-level *standard-output*))
    (bt:make-thread
      (lambda ()
        (format top-level "Started compilation thread!~%")
        (open-fsnotify)
        (mapc-directory-tree (lambda (x) (if (not (pathname-name x)) (add-watch x))) (asdf:system-source-directory :spickipedia))
        (loop while t do
          (if (get-events)
            (progn
              (format top-level "Got a code update!~%")
              (handler-case
                (asdf:load-system :spickipedia)
                (error () (format top-level "Failed compiling!~%"))))
            (sleep 1)))))))
