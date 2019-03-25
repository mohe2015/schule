(var __-p-s_-m-v_-r-e-g)

(i "./update-state.lisp" "updateState")

(export
 (defun push-state (url data)
   (chain window history (push-state data nil url))
   (update-state)))
