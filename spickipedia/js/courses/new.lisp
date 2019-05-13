(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")

(defroute "/courses/new"
    (let ((select (chain document (query-selector "#teachers-select"))))
      (setf (chain select inner-h-t-m-l) "")
      (chain
       (fetch "/api/teachers")
       (then check-status)
       (then json)
       (then
        (lambda (data)
           (chain console (log data))
           (loop for teacher in data do
                 (let ((element (chain document (create-element "option"))))
                  (setf (chain element inner-text) (chain teacher name))
                  (setf (chain element value) (chain teacher teacher-id))
                  (chain select (append-child element))))))
       (catch handle-fetch-error))
      (show-tab "#create-course-tab")))

(chain
  ($ "#create-course-form")
  (submit
    (lambda (event)
      (let* ((formElement (chain document (query-selector "#create-course-form")))
             (formData (new (-Form-Data formElement))))
        (chain formData (append "_csrf_token" (read-cookie "_csrf_token")))
        (chain
          (fetch
            "/api/courses"
            (create
              method "POST"
              body formData))
          (then check-status)
          (then json)
          (then
            (lambda (data)
              (alert data)))
          (catch handle-fetch-error)))
      F)))
