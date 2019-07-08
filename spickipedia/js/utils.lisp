(var __-p-s_-m-v_-r-e-g)

(export (defun one (selector) (chain document (query-selector selector))))

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


(export
 (defun all (selector)
   (chain -array (from (chain document (query-selector-all selector))))))

(export
 (defun clear-children (element)
   (while (chain element (has-child-nodes))
    (chain element (remove-child (chain element last-child))))))
