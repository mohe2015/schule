(var __-p-s_-m-v_-r-e-g)

(export
  (defun handle-fetch-error (error)
    (chain console (log (chain error response)))
    (alert "error")))

(export
  (defun check-status (response)
    (if (and (>= (chain response status) 200) (< (chain response status) 300))
      (chain -Promise (resolve response))
      (let ((error (new (-error (chain response status-text)))))
        (setf (chain error response) response)
        (throw error)))))

(export
  (defun json (response)
    (chain response (json))))
