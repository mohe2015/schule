(var __-p-s_-m-v_-r-e-g)

(i "./editor.lisp" "hideEditor")
(i "./utils.lisp" "all" "one" "clearChildren")

;; TODO deprecate
(export
 (defun cleanup ()
   (hide-editor)
   (hide-modal (one "#modal-publish-changes"))
   (show-element (one "#publish-changes"))
   (hide-element (one "#publishing-changes"))))
