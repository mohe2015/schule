(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./hide-editor.lisp" "hideEditor")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(export
 (defun cleanup ()
   (hide-editor)
   (chain (one "#publish-changes-modal") (modal "hide"))
   (chain (one "#publish-changes") (show))
   (chain (one "#publishing-changes") (hide))))
