(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./hide-editor.lisp" "hideEditor")
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun cleanup ()
   (hide-editor)
   (hide-modal (one "#publish-changes-modal"))
   (show (one "#publish-changes"))
   (hide (one "#publishing-changes"))))
