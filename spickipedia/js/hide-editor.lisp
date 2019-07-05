
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(export
 (defun hide-editor ()
   (chain ($ "#editor") (add-class "d-none"))
   (chain ($ "article") (attr "contenteditable" f))
   (chain ($ ".article-editor") (remove-class "fullscreen")))) 