
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun show-tab (id)
   (chain (one ".my-tab") (not id) (hide))
   (chain (one id) (show))))
