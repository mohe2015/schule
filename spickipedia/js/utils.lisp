(var __-p-s_-m-v_-r-e-g)

(export
  (defun one (selector)
    (chain document (query-selector selector))))

(export
  (defun all (selector)
    (chain document (query-selector-all selector))))

(export
  (defun clear-children (element)
    (while (chain element (has-child-nodes))
      (chain element (remove-child (chain element last-child))))))

(export
  (defun internal-onclicks (elements handler)
    (chain
      elements
      (for-each
        (lambda (element)
          (chain element (add-event-listener "click" handler)))))))

(export
  (defun show-modal (element)
    (chain ($ element) (modal "show"))))

(export
  (defun hide-modal (element)
    (chain ($ element) (modal "hide"))))
