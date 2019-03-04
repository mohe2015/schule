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
 :csrf
 (lambda (app)
   (lambda (env)
     (let* ((res (funcall app env))
	    (response (apply #'lack.response:make-response res)))
       (setf (getf (lack.response:response-set-cookies response) "_csrf_token") `(:value ,(lack.middleware.csrf:csrf-token (getf env :lack.session))))
       (lack.response:finalize-response response))))
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((mito:*mito-logger-stream* t))
           (funcall app env)))))
 *web*)
