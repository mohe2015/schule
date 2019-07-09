
(var __-p-s_-m-v_-r-e-g)

(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun hide-editor ()
   (add-class (one "#editor") "d-none")
   (setf (content-editable (one "article")) f)
   (remove-class (one ".article-editor") "fullscreen")))
