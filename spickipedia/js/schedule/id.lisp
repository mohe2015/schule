(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../utils.lisp" "showModal" "internalOnclicks" "all" "one")

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

(onclicks ".add-course"
  (show-modal (one "#schedule-data-modal")))
