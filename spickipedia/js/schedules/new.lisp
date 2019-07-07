(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../read-cookie.lisp" "readCookie")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../push-state.lisp" "pushState")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/schedules/new"
  (show-tab "#create-schedule-tab"))

(on "submit" "#create-schedule-form" event
  (let* ((formelement
          (chain document (query-selector "#create-schedule-form")))
         (formdata (new (-form-data formelement))))
    (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
    (chain (fetch "/api/schedules" (create method "POST" body formdata))
     (then check-status) (then json)
     (then
      (lambda (data)
        (push-state "/schedules")
        (setf (chain (one "#schedule-grade") value) "")))
     (catch handle-fetch-error)))
  f)
