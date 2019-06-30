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

(chain
  ($ "#create-schedule-form")
  (submit
    (lambda (event)
      (let* ((formElement (chain document (query-selector "#create-schedule-form")))
             (formData (new (-Form-Data formElement))))
        (chain formData (append "_csrf_token" (read-cookie "_csrf_token")))
        (chain
          (fetch
            "/api/schedules"
            (create
              method "POST"
              body formData))
          (then check-status)
          (then json)
          (then
            (lambda (data)
              (push-state "/schedules")
              (setf (chain (one "#schedule-grade") value) "")))
          (catch handle-fetch-error)))
      F)))
