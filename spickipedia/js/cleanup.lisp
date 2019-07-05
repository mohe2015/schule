
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(i "./hide-editor.lisp" "hideEditor") 
(export
 (defun cleanup ()
   (hide-editor)
   (chain ($ "#publish-changes-modal") (modal "hide"))
   (chain ($ "#publish-changes") (show))
   (chain ($ "#publishing-changes") (hide)))) 