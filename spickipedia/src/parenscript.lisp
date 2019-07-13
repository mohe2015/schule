(in-package :spickipedia.parenscript)

(defparameter *js-target-version* "1.8.5")

(defpsmacro defroute (route &body body)
  `(progn
     (export
       (defun ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "/[:\\.]?" route "-") 1))) (path)
         (var results nil)
         (when (var results (chain (new (-reg-exp ,(concatenate 'string "^" (regex-replace-all "\\.[^/]*" (regex-replace-all ":[^/]*" route "([^/]*)") "(.*)") "$"))) (exec path)))
               ,@(loop for variable in (all-matches-as-strings "[:.][^/]*" route) for i from 1 collect
                   `(defparameter ,(make-symbol (string-upcase (subseq variable 1))) (chain results ,i)))
               ,@body
               (return t))
         (return f)))
     (chain (setf (chain window routes) (or (chain window routes) ([])))
            (push ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "/[:\\.]?" route "-") 1)))))))

(defpsmacro i (file &rest contents) `(import ,file ,@contents))

(defun file-js-gen (file)
  (in-package :spickipedia.parenscript)
  (handler-bind ((simple-warning
                  #'(lambda (e)
                      (if (equal "Returning from unknown block ~A" (simple-condition-format-control e))
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

(defpsmacro class-list (element)
  `(chain ,element class-list))

(defpsmacro array-remove (array element)
  `(chain ,array (remove ,element)))

(defpsmacro add (array element)
  `(chain ,array (add ,element)))

(defpsmacro remove-class (element class)
  `(array-remove (class-list ,element) ,class))

(defpsmacro add-class (element class)
  `(add (class-list ,element) ,class))

(defpsmacro content-editable (element)
  `(chain ,element content-editable))

(defpsmacro style (element)
  `(chain ,element style))

(defpsmacro display (element)
  `(chain ,element display))

(defpsmacro show (element)
  `(remove-class ,element "d-none"))

(defpsmacro hide (element)
  `(add-class ,element "d-none"))

(defpsmacro show-modal (element)
  `(chain (bootstrap.-Modal.get ,element) (show)))

(defpsmacro hide-modal (element)
  `(chain (bootstrap.-Modal.get ,element) (hide)))

(defpsmacro value (element)
  `(chain ,element value))

(defpsmacro disabled (element)
  `(chain ,element disabled))

(defpsmacro remove (element)
  `(chain ,element (remove)))

(defpsmacro href (element)
  `(chain ,element href))

(defpsmacro focus (element)
  `(chain ,element (focus)))

(defpsmacro before (element new-element)
  `(chain ,element (before ,new-element)))

(defpsmacro append (element new-element)
  `(chain ,element (append ,new-element)))
