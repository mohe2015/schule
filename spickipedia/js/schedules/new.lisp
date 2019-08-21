(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../state-machine.lisp" "pushState")
(i "../utils.lisp" "all" "one" "clearChildren")

(defroute "/schedules/new"
    (show-tab "#create-schedule-tab"))

(on ("submit" (one "#create-schedule-form") event)
    (let* ((formelement (one "#create-schedule-form"))
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
