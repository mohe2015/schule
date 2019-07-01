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
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace
       :output ,(getf (config) :error-log))
     nil)
 :session
 :csrf
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((mito:*mito-logger-stream* t))
           (funcall app env)))))
 *web*)
