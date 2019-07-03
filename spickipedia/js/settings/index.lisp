(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "cacheThenNetwork" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../push-state.lisp" "pushState")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defun render ()
  (show-tab "#loading")
  (cache-then-network
    "/api/schedules"
    (lambda (data)
      (let ((grade-select (one "#settings-select-grade")))
        (clear-children grade-select)
        (let ((default-option (chain document (create-element "option")))) ;; TODO use template
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
        (cache-then-network
          "/api/settings"
          (lambda (data)
            (setf (chain grade-select value) (chain data id))

            (chain
              (fetch "/api/courses")
              (then check-status)
              (then json)
              (then
                (lambda (data)
                  (let ((courses-list (chain document (get-element-by-id "settings-list-courses"))))
                    (setf (chain courses-list inner-h-t-m-l) "")
                    (loop for page in data do
                        (let ((template (get-template "courses-list-html")))
                          (setf (chain template (query-selector ".courses-list-subject") inner-text) (chain page subject))
                          (chain courses-list (append template)))))
                  (show-tab "#tab-settings")))
              (catch handle-fetch-error)))))))
  (let ((select (chain document (query-selector "#settings-teachers-select"))))
    (setf (chain select inner-h-t-m-l) "")
    (chain
     (fetch "/api/teachers")
     (then check-status)
     (then json)
     (then
      (lambda (data)
         (loop for teacher in data do
               (let ((element (chain document (create-element "option"))))
                (setf (chain element inner-text) (chain teacher name))
                (setf (chain element value) (chain teacher id))
                (chain select (append-child element))))))
     (catch handle-fetch-error))))

(defroute "/settings"
  (render))

(chain
  (one "#settings-add-grade")
  (add-event-listener "click"
    (lambda (event)
      (chain event (prevent-default))
      (show-modal "#modal-settings-create-grade"))))

(chain
  (one "#settings-add-course")
  (add-event-listener "click"
    (lambda (event)
      (chain event (prevent-default))
      (show-modal "#modal-settings-create-course"))))

(chain
  ($ "#form-settings-create-grade")
  (submit
    (lambda (event)
      (chain event (prevent-default))
      (let* ((formElement (chain document (query-selector "#form-settings-create-grade")))
             (formData (new (-Form-Data formElement))))
        (chain formData (append "_csrf_token" (read-cookie "_csrf_token")))
        (chain
          (fetch
            "/api/schedules"
            (create
              method "POST"
              body formData))
          (then check-status)
          (then
            (lambda (data)
              (hide-modal "#modal-settings-create-grade")
              (render)))
          (catch handle-fetch-error)))
      F)))

(chain
  (one "#settings-select-grade")
  (add-event-listener "change"
    (lambda (event)
      (let* ((formElement (chain document (query-selector "#settings-form-select-grade")))
             (formData (new (-Form-Data formElement))))
        (chain formData (append "_csrf_token" (read-cookie "_csrf_token")))
        (chain
          (fetch ;; TODO loading indicator
            "/api/settings"
            (create
              method "POST"
              body formData))
          (then check-status)
          (then
            (lambda (data)
              nil))
          (catch handle-fetch-error)))
      F)))

;;
