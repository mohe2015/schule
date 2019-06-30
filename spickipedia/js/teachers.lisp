(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./handle-error.lisp" "handleError")
(i "./fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "./template.lisp" "getTemplate")
(i "./push-state.lisp" "pushState")

(defroute "/teachers/new"
  (show-tab "#create-teacher-tab"))

(defroute "/teachers"
  (show-tab "#list-teachers")

  (chain
    (fetch "/api/teachers")
    (then check-status)
    (then json)
    (then
      (lambda (data)
        (if (null data)
          (setf data ([])))
        (let ((teachers-list (chain document (get-element-by-id "teachers-list"))))
          (setf (chain teachers-list inner-h-t-m-l) "")
          (loop for page in data do
              (let ((template (get-template "teachers-list-html")))
                (chain console (log (chain page name)))
                (setf (chain template (query-selector ".teachers-list-name") inner-text) (chain page name))
                (chain document (get-element-by-id "teachers-list") (append template)))))))
    (catch handle-fetch-error)))

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
          (then json)
          (then
            (lambda (data)
              (push-state "/teachers")))
          (catch handle-fetch-error)))
      F)))
