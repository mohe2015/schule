(var __-p-s_-m-v_-r-e-g)

(import "./update-state.lisp" "updateState")

(export
 (defun replace-state (url data)
   (chain window history (replace-state data nil url))
   (update-state)))
