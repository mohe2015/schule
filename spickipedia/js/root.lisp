(var __-p-s_-m-v_-r-e-g)


(i "./state-machine.lisp" "replaceState")
(i "./utils.lisp" "all" "one" "clearChildren")

(defroute "/"
  (remove-class (all ".edit-button") "disabled")
  (replace-state "/wiki/Hauptseite"))
