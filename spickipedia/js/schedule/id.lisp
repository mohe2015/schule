
(var __-p-s_-m-v_-r-e-g)
(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError"
 "cacheThenNetwork")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")
(i "../template.lisp" "getTemplate")
(i "../read-cookie.lisp" "readCookie")
(defroute "/schedule/:grade" (show-tab "#schedule")
 (chain (fetch (concatenate 'string "/api/schedule/" grade))
  (then check-status) (then json)
  (then
   (lambda (data)
     (loop for element in (chain data data)
           do (chain console (log element)) (let* ((cell1
                                                    (getprop
                                                     (one "#schedule-table")
                                                     'children
                                                     (chain element weekday)))
                                                   (cell2
                                                    (chain cell1
                                                     (query-selector "tbody")))
                                                   (cell
                                                    (getprop cell2 'children
                                                     (- (chain element hour) 1)
                                                     'children 1))
                                                   (template
                                                    (get-template
                                                     "schedule-data-cell-template")))
                                              (setf (chain template
                                                     (query-selector ".data")
                                                     inner-text)
                                                    (concatenate 'string
                                                                 (chain
                                                                  element
                                                                  course
                                                                  subject)
                                                                 " "
                                                                 (chain
                                                                  element
                                                                  course
                                                                  type)
                                                                 " "
                                                                 (chain
                                                                  element
                                                                  course
                                                                  teacher
                                                                  name)
                                                                 " "
                                                                 (chain
                                                                  element
                                                                  room)))
                                              (chain template
                                               (query-selector
                                                ".button-delete-schedule-data")
                                               (set-attribute "data-id"
                                                (chain element id)))
                                              (chain cell
                                               (prepend template))))))
  (catch handle-fetch-error)))
(chain (one "#schedule-data-form")
 (add-event-listener "submit"
  (lambda (event)
    (chain event (prevent-default))
    (let* ((day (chain (one "#schedule-data-weekday") value))
           (hour (chain (one "#schedule-data-hour") value))
           (cell1 (getprop (one "#schedule-table") 'children day))
           (cell2 (chain cell1 (query-selector "tbody")))
           (cell (getprop cell2 'children (- hour 1) 'children 1))
           (template (get-template "schedule-data-cell-template"))
           (course (chain (one "#course") selected-options 0 inner-text))
           (room (chain (one "#room") value))
           (form-element
            (chain document (query-selector "#schedule-data-form")))
           (form-data (new (-form-data form-element)))
           (grade (chain location pathname (split "/") 2)))
      (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain
       (fetch (concatenate 'string "/api/schedule/" grade "/add")
        (create method "POST" body form-data))
       (then check-status) (then json)
       (then
        (lambda (data)
          (setf (chain template (query-selector ".data") inner-text)
                (concatenate 'string course " " room))
          (chain cell (prepend template))
          (hide-modal (one "#schedule-data-modal"))))
       (catch handle-fetch-error))))))
(chain (all ".add-course")
 (on "click"
  (lambda (event)
    (chain console (log event))
    (let* ((y (chain event target (closest "tr") row-index))
           (x-element (chain event target (closest "div")))
           (x
            (chain -array (from (chain x-element parent-node children))
             (index-of x-element))))
      (setf (chain (one "#schedule-data-weekday") value) x)
      (setf (chain (one "#schedule-data-hour") value) y)
      (show-modal (one "#schedule-data-modal"))))))
(chain (one "body")
 (add-event-listener "click"
  (lambda (event)
    (if (not (chain event target (closest ".button-delete-schedule-data")))
        (return))
    (chain console (log event))
    (let* ((id
            (chain event target (closest ".button-delete-schedule-data")
             (get-attribute "data-id")))
           (form-data (new (-form-data)))
           (grade (chain location pathname (split "/") 2)))
      (chain form-data (append "id" id))
      (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
      (if (confirm "Möchtest du den Eintrag wirklich löschen?")
          (chain
           (fetch (concatenate 'string "/api/schedule/" grade "/delete")
            (create method "POST" body form-data))
           (then check-status)
           (then
            (lambda (data)
              (chain event target (closest ".schedule-data") (remove))))
           (catch handle-fetch-error)))))))
(cache-then-network "/api/courses"
 (lambda (data)
   (let ((course-select (one "#course")))
     (clear-children course-select)
     (loop for course in data
           do (let ((option (chain document (create-element "option")))
                    (text
                     (concatenate 'string (chain course subject) " "
                                  (chain course type) " "
                                  (chain course teacher name))))
                (setf (chain option value) (chain course course-id))
                (setf (chain option inner-text) text)
                (chain course-select (append-child option)))))))
