(var __-p-s_-m-v_-r-e-g)

(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../push-state.lisp" "pushState")
(i "../utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/settings"
  (show-tab "#tab-settings")
  nil)
