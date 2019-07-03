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
            (show-tab "#tab-settings")))))))

(defroute "/settings"
  (render))

(chain
  (one "#settings-add-grade")
  (add-event-listener "click"
    (lambda (event)
      (chain event (prevent-default))
      (show-modal "#modal-settings-create-grade"))))

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
