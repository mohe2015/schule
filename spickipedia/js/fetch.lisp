(var __-p-s_-m-v_-r-e-g)

(i "./push-state.lisp" "pushState")

(export
  (defun handle-fetch-error (error)
    (chain console (log (chain error)))
    (let ((status (chain error response status)))
      (if (= status 401)
       (let ((name (chain ($ "#inputName") (val (chain window local-storage name)))))
         (chain window local-storage (remove-item "name"))
         (push-state "/login" (create last-url (chain window location href) last-state (chain window history state))))
       (if (= status 403)
           (let ((error-message "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
             (alert error-message))
           (let ((error-message (concatenate 'string "Unbekannter Fehler: " (chain error response status-text))))
             (alert error-message)))))))

(export
  (defun handle-fetch-error-show (error)
    (chain console (log (chain error)))
    (let ((status (chain error response status)))
      (if (= status 401)
       (let ((name (chain ($ "#inputName") (val (chain window local-storage name)))))
         (chain window local-storage (remove-item "name"))
         (push-state "/login" (create last-url (chain window location href) last-state (chain window history state))))
       (if (= status 403)
           (let ((error-message "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
             (chain ($ "#errorMessage") (text error-message))
             (show-tab "#error"))
           (let ((error-message (concatenate 'string "Unbekannter Fehler: " (chain error response status-text))))
             (chain ($ "#errorMessage") (text error-message))
             (show-tab "#error")))))))

(export
  (defun check-status (response)
    (if (= (chain response status) 200)
      (chain -Promise (resolve response))
      (let ((error (new (-error (chain response status-text)))))
        (setf (chain error response) response)
        (throw error)))))

(export
  (defun json (response)
    (if (not response) (throw (new (-Error "No data"))))
    (chain response (json))))

(export
  (defun html ()
    (chain response (text))))

(export
  (defun cache-then-network (url callback)
    (var networkDataReceived F)
    ;; (startSpinner)
    ;; fetch fresh data
    (var
      networkUpdate
      (chain
        (fetch url)
        (then json)
        (then (lambda (data)
                (setf networkDataReceived T)
                (callback data)))))
    ;; fetch cached data
    (chain
      caches
      (match url)
      (then json)
      (then (lambda (data)
              ;; don't overwrite newer network data
              (if (not networkDataReceived)
                (callback data))))
      (catch (lambda()
               ;; we didn't get cached data, the network is our last hope:
               networkUpdate)))))
    ;;  (catch handle-fetch-error)))
    ;;  (then stopSpinner))
