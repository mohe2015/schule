(var __-p-s_-m-v_-r-e-g)

(export
 (defun hide-editor ()
   (chain ($ "#editor") (add-class "d-none"))
   (chain ($ "article") (attr "contenteditable" F))
   (chain ($ ".article-editor") (remove-class "fullscreen"))))
