(var __-p-s_-m-v_-r-e-g)

(setf (chain -Array prototype hide)
      (lambda ()
        (chain this
               (for-each
                (lambda (element)
                    (hide element))))
        this))

(setf (chain -Array prototype remove)
      (lambda ()
        (chain this
               (for-each
                (lambda (element)
                    (remove element))))
        this))

(setf (chain -Array prototype add-event-listener)
      (lambda (event func)
        (chain this
               (for-each
                (lambda (element)
                    (chain element (add-event-listener event func)))))
        this))

;; THIS IS HACKY AS HELL AND SHOULD PROBABLY AT LEAST BE IMPLEMENTED USING A SUBCLASS
(chain
 -object
 (define-property
     (chain -Array prototype)
     "classList"
   (create
    get
    (lambda ()
      (let ((result (chain this (map (lambda (e) (chain e class-list))))))
        (setf
         (chain result remove)
         (lambda (clazz)
           (chain this
                  (for-each
                   (lambda (element)
                     (chain element (remove clazz)))))))

        (setf
         (chain result add)
         (lambda (clazz)
           (chain this
                  (for-each
                   (lambda (element)
                     (chain element (add clazz)))))))
        result)))))

(export (defun one (selector base-element) (chain (or base-element document) (query-selector selector))))

(export
 (defun all (selector base-element)
   (chain -array (from (chain (or base-element document) (query-selector-all selector))))))

(export
 (defun clear-children (element)
   (while (chain element (has-child-nodes))
     (chain element (remove-child (chain element last-child))))))
