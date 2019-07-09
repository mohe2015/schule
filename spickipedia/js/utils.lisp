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

(export (defun one (selector base-element) (chain (or base-element document) (query-selector selector))))

(export
 (defun all (selector base-element)
   (chain -array (from (chain (or base-element document) (query-selector-all selector))))))

(export
 (defun clear-children (element)
   (while (chain element (has-child-nodes))
    (chain element (remove-child (chain element last-child))))))
