(export-default
 (defun hide-editor ()
   (chain ($ "#editor") (add-class "d-none"))
   (chain ($ "article") (attr "contenteditable" F))
   (chain ($ ".article-editor") (remove-class "fullscreen"))))
