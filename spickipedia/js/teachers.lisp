(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./handle-error.lisp" "handleError")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchError")

(defroute "/teachers/new"
  (show-tab "#create-teacher-tab"))

;; TODO do it like this everywhere
(chain
  ($ "#create-teacher-form")
  (submit
    (lambda (event)
      (let* ((formElement (chain document (query-selector "#create-teacher-form")))
             (formData (new (-Form-Data formElement))))
        (chain formData (append "_csrf_token" (read-cookie "_csrf_token")))
        (chain
          (fetch
            "/api/teachers"
            (create
              method "POST"
              body formData))
          (then check-status)
          (then
            (lambda (data)
              (alert data)))
          (catch handle-fetch-error)))
      F)))
