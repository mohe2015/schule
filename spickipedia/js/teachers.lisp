(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")

(defroute "/teachers/new"
  (show-tab "#create-teacher-tab"))

(chain
  ($ "#create-teacher-form")
  (submit
    (lambda (event)
      (chain ($ ".csrf-token") (val (read-cookie "_csrf_token"))))))
