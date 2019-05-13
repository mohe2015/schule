(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")

(defroute "/schedule/:id"
  (var pathname (chain window location pathname (split "/")))

  (show-tab "#schedule"))
