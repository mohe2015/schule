(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./replace-state.lisp" "replaceState")
(i "./utils.lisp" "all" "one" "clearChildren")

(defroute "/"
  (remove-class (one ".edit-button") "disabled")
  (replace-state "/wiki/Hauptseite"))
