
(var __-p-s_-m-v_-r-e-g)
(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "cacheThenNetwork" "checkStatus" "json" "html"
 "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../push-state.lisp" "pushState") 
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")
(defun render ()
  (show-tab "#loading")
  (cache-then-network "/api/schedules"
   (lambda (data)
     (let ((grade-select (one "#settings-select-grade")))
       (clear-children grade-select)
       (let ((default-option (chain document (create-element "option"))))
         (setf (chain default-option disabled) t)
         (setf (chain default-option selected) t)
         (setf (chain default-option value) "")
         (setf (chain default-option inner-text) "Jahrgang auswählen...")
         (chain grade-select (append-child default-option)))
       (loop for grade in data
             do (let ((option (chain document (create-element "option")))
                      (text (chain grade grade)))
                  (setf (chain option value) (chain grade id))
                  (setf (chain option inner-text) text)
                  (chain grade-select (append-child option))))
       (cache-then-network "/api/settings"
        (lambda (data)
          (if data
              (setf (chain grade-select value) (chain data id)))
          (chain (fetch "/api/courses") (then check-status) (then json)
           (then
            (lambda (data)
              (let ((courses-list
                     (chain document
                      (get-element-by-id "settings-list-courses"))))
                (setf (chain courses-list inner-h-t-m-l) "")
                (loop for page in data
                      do (let ((template
                                (get-template "settings-student-course-html"))
                               (id
                                (concatenate 'string "student-course-"
                                             (chain page course-id))))
                           (setf (chain template (query-selector "label")
                                  inner-text)
                                 (chain page subject))
                           (chain template (query-selector "label")
                            (set-attribute "for" id))
                           (setf (chain template (query-selector "input") id)
                                 id)
                           (chain courses-list (append template)))))
              (chain (fetch "/api/student-courses") (then check-status)
               (then json)
               (then
                (lambda (data)
                  (loop for student-course in data
                        do (setf (chain document
                                  (get-element-by-id
                                   (concatenate 'string "student-course-"
                                                (chain student-course course
                                                 course-id)))
                                  checked)
                                 t)))))
              (show-tab "#tab-settings")))
           (catch handle-fetch-error)))))))
  (let ((select (chain document (query-selector "#settings-teachers-select"))))
    (setf (chain select inner-h-t-m-l) "")
    (chain (fetch "/api/teachers") (then check-status) (then json)
     (then
      (lambda (data)
        (loop for teacher in data
              do (let ((element (chain document (create-element "option"))))
                   (setf (chain element inner-text) (chain teacher name))
                   (setf (chain element value) (chain teacher id))
                   (chain select (append-child element))))))
     (catch handle-fetch-error))))
(defroute "/settings" (render))
(chain (one "#settings-add-grade")
 (add-event-listener "click"
  (lambda (event)
    (chain event (prevent-default))
    (show-modal "#modal-settings-create-grade"))))
(chain (one "#settings-add-course")
 (add-event-listener "click"
  (lambda (event)
    (chain event (prevent-default))
    (show-modal "#modal-settings-create-course"))))
(chain (one "#settings-show-schedule")
 (add-event-listener "click"
  (lambda (event)
    (chain event (prevent-default))
    (let* ((select
            (chain document (get-element-by-id "settings-select-grade")))
           (grade
            (getprop select 'options (chain select selected-index) 'text)))
      (push-state (concatenate 'string "/schedule/" grade))))))
(chain ($ "#form-settings-create-grade")
 (submit
  (lambda (event)
    (chain event (prevent-default))
    (let* ((formelement
            (chain document (query-selector "#form-settings-create-grade")))
           (formdata (new (-form-data formelement))))
      (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain (fetch "/api/schedules" (create method "POST" body formdata))
       (then check-status)
       (then
        (lambda (data) (hide-modal "#modal-settings-create-grade") (render)))
       (catch handle-fetch-error)))
    f)))
(chain (one "#settings-select-grade")
 (add-event-listener "change"
  (lambda (event)
    (let* ((formelement
            (chain document (query-selector "#settings-form-select-grade")))
           (formdata (new (-form-data formelement))))
      (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain (fetch "/api/settings" (create method "POST" body formdata))
       (then check-status) (then (lambda (data) (render)))
       (catch handle-fetch-error)))
    f)))
(chain ($ "#form-settings-create-course")
 (submit
  (lambda (event)
    (chain event (prevent-default))
    (let* ((formelement
            (chain document (query-selector "#form-settings-create-course")))
           (formdata (new (-form-data formelement))))
      (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain (fetch "/api/courses" (create method "POST" body formdata))
       (then check-status)
       (then
        (lambda (data) (hide-modal "#modal-settings-create-course") (render)))
       (catch handle-fetch-error)))
    f)))
(chain (one "body")
 (add-event-listener "change"
  (lambda (event)
    (if (not (chain event target (closest ".student-course-checkbox")))
        (return))
    (let* ((formdata (new (-form-data))))
      (chain console (log (chain event target)))
      (chain formdata
       (append "student-course"
               (chain (chain event target id) (substring 15))))
      (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
      (if (chain event target checked)
          (chain
           (fetch "/api/student-courses" (create method "POST" body formdata))
           (then check-status) (then (lambda (data) nil))
           (catch handle-fetch-error))
          (chain
           (fetch "/api/student-courses"
            (create method "DELETE" body formdata))
           (then check-status) (then (lambda (data) nil))
           (catch handle-fetch-error))))
    f)))
