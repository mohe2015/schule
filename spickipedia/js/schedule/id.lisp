(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")

(defroute "/schedule/:id"
  (show-tab "#schedule")

  (chain
    (fetch (concatenate 'string "/api/schedule/" id))
    (then check-status)
    (then json)
    (then
      (lambda (data)
        nil))
    (catch handle-fetch-error)))

(defun one (selector)
  (chain document (query-selector selector)))

(defun all (selector)
  (chain document (query-selector-all selector)))

(defun onclicks (elements handler)
  (chain
    elements
    (for-each
      (lambda (element)
        (chain element (add-event-listener "click" handler))))))

(onclicks (all ".add-course")
          (lambda (e)
            (alert 1)))
