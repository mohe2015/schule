(in-package :cl-user)
(defpackage spickipedia.parenscript
  (:use :cl :parenscript :ppcre :ironclad)
  (:export :file-js-gen
       :js-files))
(in-package :spickipedia.parenscript)

(defparameter *js-target-version* "1.8.5")

(defpsmacro defroute (route &body body)
  `(progn
     (export
      (defun ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/[:\\.]?" route "-") 1))) (path)
       (if (not (null (var results (chain (new (-Reg-Exp ,(concatenate 'string "^" (regex-replace-all "\\.[^/]*" (regex-replace-all ":[^/]*" route "([^/]*)") "(.*)") "$"))) (exec path)))))
           (progn
             ,@(loop
                for variable in (all-matches-as-strings "[:\.][^/]*" route)
                for i from 1
                collect
                `(defparameter ,(make-symbol (string-upcase (subseq variable 1))) (chain results ,i)))
             ,@body
             (return T)))
       (return F)))
     (chain window routes (push ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/[:\\.]?" route "-") 1)))))))


(defpsmacro get (url show-error-page &body body)
  `(chain $
      (get ,url (lambda (data) ,@body))
      (fail (lambda (jq-xhr text-status error-thrown)
             (handle-error jq-xhr ,show-error-page)))))

(defpsmacro post (url data show-error-page &body body)
  `(chain $
      (post ,url ,data (lambda (data) ,@body))
      (fail (lambda (jq-xhr text-status error-thrown)
             (handle-error jq-xhr ,show-error-page)))))

(defpsmacro i (file &rest contents)
  `(import ,file ,@contents))


(defpsmacro onclicks (selector &body body)
  `(internal-onclicks (all ,selector)
          (lambda (event)
            ,@body)))

(defpsmacro onsubmit (selector &body body)
  `(chain
     (one ,selector)
     (add-event-listener
       "submit" (lambda (event)
                  ,@body))))

(defpsmacro onclick (selector &body body)
  `(chain
     (one ,selector)
     (add-event-listener
       "click" (lambda (event)
                  ,@body))))

(defun file-js-gen (file)
  (in-package :spickipedia.parenscript)
  (handler-bind ((simple-warning #'(lambda (e) (if (equal "Returning from unknown block ~A" (simple-condition-format-control e)) (muffle-warning)))))
    (defparameter *PS-GENSYM-COUNTER* 0)
    (ps-compile-file file)))
