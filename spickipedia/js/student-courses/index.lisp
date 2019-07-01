(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../utils.lisp" "showModal")

(defroute "/student-courses"
  (show-tab "#list-student-courses")

  (show-modal ($ "#student-courses-modal"))

  (chain
    (fetch "/api/courses")
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
    (catch handle-fetch-error)))
