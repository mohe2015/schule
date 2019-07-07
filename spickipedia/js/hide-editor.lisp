
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(export
 (defun hide-editor ()
   (chain (one "#editor") (add-class "d-none"))
   (chain (one "article") (attr "contenteditable" f))
   (chain (one ".article-editor") (remove-class "fullscreen")))) 