(export-default
 (defun push-state (url data)
   (chain window history (push-state data nil url))
   (update-state)))
