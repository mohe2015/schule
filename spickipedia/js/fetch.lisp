(var __-p-s_-m-v_-r-e-g)

(export
  (defun handle-fetch-error (error)
    (chain console (log error))
    (alert "error")))

(export
  (defun check-status (response)
    (if (and (>= (chain response status) 200) (< (chain response status) 300))
      (chain -Promise (resolve response))
      (chain -promise (reject (new (-error (chain response status-text))))))))

(export
  (defun json (response)
    (chain response (json))))
