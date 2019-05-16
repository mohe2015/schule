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

(let ((table (chain document (get-element-by-id "schedule-table"))))
  (dotimes (i (getprop table 'rows 'length))
      (dotimes (j (getprop table 'rows i 'cells 'length))
            (setf (getprop table 'rows i 'cells j 'onclick)
                  (lambda ()
                    (alert 1))))))
