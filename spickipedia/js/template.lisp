(var __-p-s_-m-v_-r-e-g)

(export
  (defun get-template (id)
    (chain document (import-node (chain document (get-element-by-id id) content) T))))