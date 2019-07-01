(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError" "cacheThenNetwork")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")
(i "../template.lisp" "getTemplate")
(i "../read-cookie.lisp" "readCookie")

(defroute "/schedule/:grade"
  (show-tab "#schedule")

  (chain
    (fetch (concatenate 'string "/api/schedule/" grade))
    (then check-status)
    (then json)
    (then
      (lambda (data)
        (loop for element in (chain data data) do
          (chain console (log element))
          (let* ((cell (getprop (one "#schedule-table") 'children (chain element weekday) 'children (chain element hour)))
                 (template (get-template "schedule-data-cell-template")))
            (setf (chain template (query-selector ".data") inner-text) (concatenate 'string (chain element course subject) " " (chain element course type) " " (chain element course teacher name) " " (chain element room)))
            (chain cell (prepend template))))))
    (catch handle-fetch-error))

  (chain
    (one "#schedule-data-form")
    (add-event-listener
      "submit"
      (lambda (event)
        (chain event (prevent-default))
        (let* ((x (chain (one "#schedule-data-weekday") value))
               (y (chain (one "#schedule-data-hour") value))
               (cell (getprop (one "#schedule-table") 'children x 'children y))
               (template (get-template "schedule-data-cell-template"))
               (course (chain (one "#course") selected-options 0 inner-text))
               (room (chain (one "#room") value))
               (form-element (chain document (query-selector "#schedule-data-form")))
               (form-data (new (-Form-Data form-element))))
          (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
          (chain
            (fetch
              (concatenate 'string "/api/schedule/" grade "/add")
              (create
                method "POST"
                body form-data))
            (then check-status)
            (then json)
            (then
              (lambda (data)
                (setf (chain template (query-selector ".data") inner-text) (concatenate 'string course " " room))
                (chain cell (prepend template))
                (hide-modal (one "#schedule-data-modal"))))
                ;;(alert data)))
            (catch handle-fetch-error)))))))

(chain
  (all ".add-course")
  (on
    "click"
    (lambda (event)
      (chain console (log event))
      (let ((x (chain event target (closest "td") cell-index))
            (y (chain event target (closest "tr") row-index)))
        (setf (chain (one "#schedule-data-weekday") value) x)
        (setf (chain (one "#schedule-data-hour") value) y)
        (show-modal (one "#schedule-data-modal"))))))

(cache-then-network
  "/api/courses"
  (lambda (data)
    (let ((course-select (one "#course")))
      (clear-children course-select)
      (loop for course in data do
        (let ((option (chain document (create-element "option")))
              (text (concatenate 'string (chain course subject) " " (chain course type) " " (chain course teacher name))))
          (setf (chain option value) (chain course course-id))
          (setf (chain option inner-text) text)
          (chain course-select (append-child option)))))))
