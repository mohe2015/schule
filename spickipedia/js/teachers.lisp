(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./handle-error.lisp" "handleError")

(defroute "/teachers/new"
  (show-tab "#create-teacher-tab"))

;; TODO do it like this everywhere
(chain
  ($ "#create-teacher-form")
  (submit
    (lambda (event)
      (let* ((formElement (chain document (query-selector "#create-teacher-form")))
             (formData (new (-Form-Data formElement)))
             (request (new -X-M-L-Http-Request)))
        (setf (chain request onload)
              (lambda (event)
                ;; todo check response code
                (alert "success")))
        (setf (chain request onerror)
              (lambda (event)
                (alert "error")))
        (chain request (open "POST" "/api/teachers"))
        (chain formData (append "_csrf_token" (read-cookie "_csrf_token")))
        (chain request (send formData)))
        ;; TODO get response
      F)))
