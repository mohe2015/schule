(ql:quickload :spickipedia)

(defpackage spickipedia.app
  (:use :cl)
  (:import-from :lack.builder
                :builder)
  (:import-from :ppcre
                :scan
                :regex-replace)
  (:import-from :spickipedia.web
                :*web*)
  (:import-from :spickipedia.config
                :config
                :productionp
                :*static-directory*))
(in-package :spickipedia.app)

(builder
 (:static
  :path (lambda (path)
	  (format t "~a~%" path)
          (if (and (cl-fad:file-exists-p (concatenate 'string "static" path)) (not (cl-fad:directory-exists-p (concatenate 'string "static" path))))
              path
              nil))
  :root *static-directory*)
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace
       :output ,(getf (config) :error-log))
     nil)
 :session
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((mito:*mito-logger-stream* t))
           (funcall app env)))))
 *web*)
