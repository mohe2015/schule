(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "cacheThenNetwork" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defun render ()
  (show-tab "#loading")
  (chain
    (fetch "/api/student-courses")
    (then check-status)
    (then json)
    (then
      (lambda (data)
        (if (null data)
          (setf data ([])))
        (let ((courses-list (chain document (get-element-by-id "student-courses-list"))))
          (setf (chain courses-list inner-h-t-m-l) "")
          (loop for course in data do
              (let ((template (get-template "student-courses-list-html")))
                (setf (chain template (query-selector ".student-courses-list-subject") inner-text) (concatenate 'string (chain course course subject) " " (chain course course type) " " (chain course course teacher name)))
                (chain template (query-selector ".button-student-course-delete") (set-attribute "data-id-student-course" (chain course course course-id)))
                (chain document (get-element-by-id "student-courses-list") (append template)))))))
    (catch handle-fetch-error))
  (show-tab "#list-student-courses"))

(defroute "/student-courses"
  (render)

  (cache-then-network
    "/api/courses"
    (lambda (data)
      (let ((course-select (one "#student-course")))
        (clear-children course-select)
        (loop for course in data do
          (let ((option (chain document (create-element "option")))
                (text (concatenate 'string (chain course subject) " " (chain course type) " " (chain course teacher name))))
            (setf (chain option value) (chain course course-id))
            (setf (chain option inner-text) text)
            (chain course-select (append-child option)))))))

  (chain
    (one "#add-student-course")
    (add-event-listener "click"
      (lambda (event)
        (chain event (prevent-default))
        (show-modal ($ "#modal-student-courses")))))

  (chain
    (one "#form-student-courses")
    (add-event-listener
      "submit"
      (lambda (event)
        (chain event (prevent-default))
        (let* ((form-element (one "#form-student-courses"))
               (form-data (new (-Form-Data form-element))))
          (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
          (chain
            (fetch
              "/api/student-courses"
              (create
                method "POST"
                body form-data))
            (then check-status)
            (then
              (lambda (data)
                (hide-modal (one "#modal-student-courses"))
                (render)))
            (catch handle-fetch-error)))))))

(chain
 ($ "body")
 (on
  "click"
  ".button-student-course-delete"
  (lambda (e)
    (let* ((form-data (new (-Form-Data))))
      (chain form-data (append "student-course" (chain ($ this) (data "id-student-course"))))
      (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain
        (fetch
          "/api/student-courses"
          (create
            method "DELETE"
            body form-data))
        (then check-status)
        (then
          (lambda (data)
            (render)))
        (catch handle-fetch-error))))))
