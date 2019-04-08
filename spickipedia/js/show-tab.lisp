(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")

(export (defun show-tab(id)
  (chain ($ ".my-tab") (not id) (fade-out))
  (chain ($ id) (fade-in))))
