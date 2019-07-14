(var __-p-s_-m-v_-r-e-g)

(i "./hide-editor.lisp" "hideEditor")
(i "./utils.lisp" "all" "one" "clearChildren")

;; TODO deprecate
(export
 (defun cleanup ()
   (hide-editor)
   (hide-modal (one "#modal-publish-changes"))
   (show (one "#publish-changes"))
   (hide (one "#publishing-changes"))))
