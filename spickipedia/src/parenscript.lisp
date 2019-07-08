(in-package :spickipedia.parenscript)

(defparameter *js-target-version* "1.8.5")

(defpsmacro defroute (route &body body)
 `(progn
   (export
    (defun ,(make-symbol
             (concatenate 'string "handle-"
                          (subseq (regex-replace-all "/[:\\.]?" route "-") 1)))
           (path)
      (var results nil)
      (if (not
           (null
            (var results
                 (chain
                  (new
                   (-reg-exp
                    ,(concatenate 'string "^"
                                  (regex-replace-all "\\.[^/]*"
                                   (regex-replace-all ":[^/]*" route "([^/]*)")
                                   "(.*)")
                                  "$")))
                  (exec path)))))
          (progn
           ,@(loop for variable in (all-matches-as-strings "[:.][^/]*" route)
                   for i from 1
                   collect `(defparameter
                                ,(make-symbol
                                  (string-upcase (subseq variable 1)))
                              (chain results ,i)))
           ,@body
           (return t)))
      (return f)))
   (chain window routes
    (push
     ,(make-symbol
       (concatenate 'string "handle-"
                    (subseq (regex-replace-all "/[:\\.]?" route "-") 1)))))))

(defpsmacro i (file &rest contents) `(import ,file ,@contents))

(defun file-js-gen (file)
  (in-package :spickipedia.parenscript)
  (handler-bind ((simple-warning
                  #'(lambda (e)
                      (if (equal "Returning from unknown block ~A"
                                 (simple-condition-format-control e))
                          (muffle-warning)))))
    (defparameter *ps-gensym-counter* 0)
    (ps-compile-file file)))

(defpsmacro on ((event-name element-s event-variable &key dynamic-selector) &body body)
  `(chain ,element-s
     (add-event-listener ,event-name
       (lambda (,event-variable)
         ,(if dynamic-selector
            `(if (not (chain event target (closest ,dynamic-selector)))
               (return)))
         ,@body))))

(defpsmacro inner-text (element)
  `(chain ,element inner-text))

(defpsmacro style (element)
  `(chain ,element style))

(defpsmacro class-list (element)
  `(chain ,element class-list))

(defpsmacro remove (array element)
  `(chain ,array (remove ,element)))

(defpsmacro add (array element)
  `(chain ,array (add ,element)))

(defpsmacro remove-class (element class)
  `(remove (class-list ,element) ,class))

(defpsmacro add-class (element class)
  `(add (class-list ,element) ,class))

(defpsmacro content-editable (element)
  `(chain ,element content-editable))

(defpsmacro show (element)
  `(chain ($ ,element) (show)))

(defpsmacro hide (element)
  `(chain ($ ,element) (hide)))

(defpsmacro show-modal (element)
  `(chain ($ ,element) (modal "show")))

(defpsmacro hide-modal (element)
  `(chain ($ ,element) (modal "hide")))
