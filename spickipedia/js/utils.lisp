(var __-p-s_-m-v_-r-e-g)

;; TODO when jquery is removed rename to $
(export
  (defun one (selector)
    (chain document (query-selector selector))))

;; TODO when jquery is removed rename to $$
(export
  (defun all (selector)
    (let ((elements (chain -Array (from (chain document (query-selector-all selector))))))
      (setf (chain elements on)
            (lambda (event handler)
              (chain this (for-each (lambda (element)
                                      (chain element (add-event-listener event handler)))))
              this))
      elements)))

(export
  (defun clear-children (element)
    (while (chain element (has-child-nodes))
      (chain element (remove-child (chain element last-child))))))

;;(export
;;  (defun internal-onclicks (elements handler)
;;    (chain
;;      elements
;;      (for-each
;;        (lambda (element)
;;          (chain element (add-event-listener "click" handler))))))

(export
  (defun show-modal (element)
    (chain ($ element) (modal "show"))))

(export
  (defun hide-modal (element)
    (chain ($ element) (modal "hide"))))
