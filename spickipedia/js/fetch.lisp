(var __-p-s_-m-v_-r-e-g)

(i "./state-machine.lisp" "pushState")
(i "./utils.lisp" "all" "one" "clearChildren")

;; TODO clean up

(export
 (defun handle-fetch-error (error)
   ;; TODO switch
   (let ((status (chain error response status)))
     (if (= status 401)
         (progn
           (setf (value (one "#inputName")) (or (chain window local-storage name) ""))
           (chain window local-storage (remove-item "name"))
           (push-state "/login"
            (create last-url (chain window location href) last-state
             (chain window history state))))
         (if (= status 403)
             (let ((error-message
                    "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
               (alert error-message))
             (let ((error-message
                    (concatenate 'string "Unbekannter Fehler: "
                                 (chain error response status-text))))
               (alert error-message)))))))

;; TODO (if (not (= text-status "abort"))
(export
 (defun handle-fetch-error-show (error)
   (chain console (log (chain error)))
   ;; TODO switch
   (let ((status (chain error response status)))
     (if (= status 401)
         (progn
           (setf (value (one "#inputName")) (or (chain window local-storage name) ""))
           (chain window local-storage (remove-item "name"))
           (push-state "/login"
            (create last-url (chain window location href) last-state
             (chain window history state))))
         (if (= status 403)
             (let ((error-message
                    "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
               (chain (one "#errorMessage") (text error-message))
               (show-tab "#error"))
             (if (= (chain error response status) 404)
                 (show-tab "#not-found")
                 (let ((error-message
                        (concatenate 'string "Unbekannter Fehler: "
                                     (chain error response status-text))))
                   (chain (one "#errorMessage") (text error-message))
                   (show-tab "#error"))))))))

(export
  (defun handle-login-error (error repeated)
    (let ((status (chain error response status)))
      (chain window local-storage (remove-item "name"))
      (if (= status 403)
          (progn
           (alert "Ungültige Zugangsdaten!")
           (chain (one "#login-button") (prop "disabled" f) (html "Anmelden")))
          (if (= status 400)
              (if repeated
                  (progn
                   (alert "Ungültige Zugangsdaten!")
                   (chain (one "#login-button") (prop "disabled" f)
                    (html "Anmelden")))
                  (login-post t))
              (handle-fetch-error error))))))

(export
 (defun check-status (response)
   (if (not response)
       (throw (new (-error "No data"))))
   (if (= (chain response status) 200)
       (chain -promise (resolve response))
       (let ((error (new (-error (chain response status-text)))))
         (setf (chain error response) response)
         (throw error)))))

(export
 (defun json (response)
   (chain response (json))))

(export
  (defun html ()
    (chain response (text))))

(export
 (defun cache-then-network (url callback)
   (var network-data-received f)
   (var network-update
        (chain
          (fetch url)
          (then check-status)
          (then json)
          (then
            (lambda (data)
              (setf network-data-received t)
              (callback data)))
          (catch handle-fetch-error-show)))
   (chain
     caches
     (match url)
     (then check-status)
     (then json)
     (then
      (lambda (data)
        (if (not network-data-received)
            (callback data))))
     (catch (lambda () network-update))
     (catch handle-fetch-error-show))))
