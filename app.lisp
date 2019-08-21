
(quicklisp-client:quickload :schule) 
(defpackage schule.app
  (:use :cl)
  (:import-from :lack.builder :builder)
  (:import-from :ppcre :scan :regex-replace)
  (:import-from :schule.web :*web*)
  (:import-from :schule.config :config :productionp :*static-directory*)) 
(in-package :schule.app) 
(builder
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace :output ,(getf (config) :error-log))
     nil)
 :session :csrf
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((mito.logger:*mito-logger-stream* t))
           (funcall app env)))))
 *web*) 