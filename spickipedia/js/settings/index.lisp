(var __-p-s_-m-v_-r-e-g)

(i "/js/show-tab.lisp" "showTab")
(i "/js/read-cookie.lisp" "readCookie")
(i "/js/fetch.lisp" "cacheThenNetwork" "checkStatus" "json" "html" "handleFetchError")
(i "/js/template.lisp" "getTemplate")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/state-machine.lisp" "enterState" "pushState")

(defun load-student-courses ()
  (chain
    (fetch "/api/student-courses")
    (then check-status)
    (then json)
    (then
     (lambda (data)
       (loop for student-course in data do
         (setf (chain document (get-element-by-id (concatenate 'string "student-course-" (chain student-course course course-id))) checked) t))))))

(defun load-courses ()
  (chain
    (fetch "/api/courses")
    (then check-status)
    (then json)
    (then
      (lambda (data)
        (let ((courses-list (chain document (get-element-by-id "settings-list-courses"))))
          (setf (chain courses-list inner-h-t-m-l) "")
          (loop for page in data do
            (let ((template (get-template "settings-student-course-html"))
                  (id (concatenate 'string "student-course-" (chain page course-id))))
              (setf (chain template (query-selector "label") inner-text) (chain page subject))
              (chain template (query-selector "label") (set-attribute "for" id))
              (setf (chain template (query-selector "input") id) id)
              (chain courses-list (append template)))))
        (load-student-courses)
        (show-tab "#tab-settings")))
    (catch handle-fetch-error)))

(defun load-teachers ()
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

(defun load-settings ()
  (let ((grade-select (one "#settings-select-grade")))
    (cache-then-network "/api/settings"
     (lambda (data)
       (if data
           (setf (chain grade-select value) (chain data id)))
       (load-courses)))))

(defun load-schedules ()
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
        (loop for grade in data do
          (let ((option (chain document (create-element "option")))
                (text (chain grade grade)))
            (setf (chain option value) (chain grade id))
            (setf (chain option inner-text) text)
            (chain grade-select (append-child option))))
        (load-settings)))))

(defun render ()
  (show-tab "#loading")
  (load-schedules)
  (load-teachers))

(defroute "/settings"
  (enter-state "handleSettings")
  (render))

(defstate handle-settings-enter
  (add-class (all ".edit-button") "disabled"))

(defstate handle-settings-exit
  (hide-modal (one "#modal-settings-create-grade"))
  (remove-class (all ".edit-button") "disabled"))

(on ("click" (one "#settings-add-grade") event)
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (show-modal (one "#modal-settings-create-grade"))
  f)

(on ("click" (one "#settings-add-course") event)
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (show-modal (one "#modal-settings-create-course"))
  f)

(on ("click" (one "#settings-show-schedule") event)
  (chain event (prevent-default))
  (let* ((select (chain document (get-element-by-id "settings-select-grade")))
         (grade (getprop select 'options (chain select selected-index) 'text)))
    (push-state (concatenate 'string "/schedule/" grade))))

(on ("submit" (one "#form-settings-create-grade") event)
  (chain event (prevent-default))
  (let* ((formelement (chain document (query-selector "#form-settings-create-grade")))
         (formdata (new (-form-data formelement))))
    (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
    (chain (fetch "/api/schedules" (create method "POST" body formdata))
      (then check-status)
      (then
        (lambda (data)
          (hide-modal (one "#modal-settings-create-grade"))
          (render)))
      (catch handle-fetch-error)))
  f)

(on ("change" (one "#settings-select-grade") event)
  (let* ((formelement (chain document (query-selector "#settings-form-select-grade")))
         (formdata (new (-form-data formelement))))
    (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
    (chain
      (fetch "/api/settings" (create method "POST" body formdata))
      (then check-status)
      (then (lambda (data) (render)))
      (catch handle-fetch-error)))
  f)

;; TODO form cancel should abort
(on ("submit" (one "#form-settings-create-course") event)
  (chain event (prevent-default))
  (setf (disabled (one "button[type=submit" (one "#form-settings-create-course"))) t)
  (let* ((formelement (chain document (query-selector "#form-settings-create-course")))
         (formdata (new (-form-data formelement))))
    (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
    (chain (fetch "/api/courses" (create method "POST" body formdata))
      (then check-status)
      (then
        (lambda (data)
          (hide-modal (one "#modal-settings-create-course"))
          (render)))
      (catch handle-fetch-error)
      (finally
        (lambda (error)
          (setf (disabled (one "button[type=submit" (one "#form-settings-create-course"))) f)))))
  f)

(on ("change" (one "body") event)
  (if (not (chain event target (closest ".student-course-checkbox")))
      (return))
  (let* ((formdata (new (-form-data))))
    (chain console (log (chain event target)))
    (chain formdata (append "student-course" (chain (chain event target id) (substring 15))))
    (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
    (if (chain event target checked)
        (chain
          (fetch "/api/student-courses" (create method "POST" body formdata))
          (then check-status)
          (catch handle-fetch-error))
        (chain
          (fetch "/api/student-courses" (create method "DELETE" body formdata))
          (then check-status)
          (catch handle-fetch-error))))
  f)
