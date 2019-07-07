
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./replace-state.lisp" "replaceState")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/" (chain (one ".edit-button") (remove-class "disabled"))
 (replace-state "/wiki/Hauptseite"))
