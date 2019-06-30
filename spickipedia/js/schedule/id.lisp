(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError" "cacheThenNetwork")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")
(i "../template.lisp" "getTemplate")

(defroute "/schedule/:id"
  (show-tab "#schedule")

  (chain
    (fetch (concatenate 'string "/api/schedule/" id))
    (then check-status)
    (then json)
    (then
      (lambda (data)
        nil))
    (catch handle-fetch-error)))

(chain
  (all ".add-course")
  (on
    "click"
    (lambda (event)
      (let ((x (chain event target (closest "td") cell-index))
            (y (chain event target (closest "tr") row-index)))
        (setf (chain (one "#schedule-data-weekday") value) x)
        (setf (chain (one "#schedule-data-hour") value) y)
        (show-modal (one "#schedule-data-modal"))))))

(chain
  (one "#save-schedule")
  (add-event-listener
    "click"
    (lambda (event)
      (setf (chain (one "#save-schedule") disabled) T)
      (let ((table (one "#schedule-table")))
        (dotimes (x (getprop table 'rows 'length))
          (dotimes (y (getprop table 'rows x 'cells 'length))
            (let ((cell (getprop table 'rows x 'cells y)))
              ;;(chain console (log cell))
              (loop for element in (chain cell (query-selector-all ".schedule-data")) do
                (chain console (log element)))))))
      (setf (chain (one "#save-schedule") disabled) F))))

(chain
  (one "#schedule-data-form")
  (add-event-listener
    "submit"
    (lambda (event)
      (chain event (prevent-default))
      (let* ((x (chain (one "#schedule-data-weekday") value))
             (y (chain (one "#schedule-data-hour") value))
             (cell (getprop (one "#schedule-table") 'rows y 'cells x))
             (template (get-template "schedule-data-cell-template"))
             (course (chain (one "#course") selected-options 0 inner-text))
             (room (chain (one "#room") value)))
        (setf (chain template (query-selector ".data") inner-text) (concatenate 'string course " " room))
        (chain cell (prepend template))
        (hide-modal (one "#schedule-data-modal"))))))

(cache-then-network
  "/api/courses"
  (lambda (data)
    (let ((course-select (one "#course")))
      (clear-children course-select)
      (loop for course in data do
        (let ((option (chain document (create-element "option")))
              (text (concatenate 'string (chain course subject) " " (chain course type) " " (chain course teacher-id))))
          (setf (chain option value) (chain course id))
          (setf (chain option inner-text) text)
          (chain course-select (append-child option)))))))
