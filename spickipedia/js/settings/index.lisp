(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "cacheThenNetwork" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../push-state.lisp" "pushState")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/settings"
  (show-tab "#tab-settings")

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
            (chain grade-select (append-child option))))))))
