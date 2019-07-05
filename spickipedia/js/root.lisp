
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(i "./replace-state.lisp" "replaceState") 
(defroute "/" (chain ($ ".edit-button") (remove-class "disabled"))
          (replace-state "/wiki/Hauptseite")) 