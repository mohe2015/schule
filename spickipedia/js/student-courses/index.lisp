(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "cacheThenNetwork" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/student-courses"
  (show-tab "#list-student-courses")

  (show-modal ($ "#student-courses-modal"))

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
          (loop for page in data do
              (let ((template (get-template "student-courses-list-html")))
                (setf (chain template (query-selector ".student-courses-list-subject") inner-text) (chain page subject))
                (chain document (get-element-by-id "student-courses-list") (append template)))))))
    (catch handle-fetch-error))


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
            (chain course-select (append-child option))))))))
