(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./handle-error.lisp" "handleError")

(defroute "/teachers/new"
  (show-tab "#create-teacher-tab"))

(chain
  ($ "#create-teacher-form")
  (submit
    (lambda (event)
      (let ((pathname (chain window location pathname (split "/"))))
        (chain ($ ".csrf-token") (val (read-cookie "_csrf_token")))
        (post "/api/teachers"
              (create
                _csrf_token (read-cookie "_csrf_token"))
          T)
        F))))
