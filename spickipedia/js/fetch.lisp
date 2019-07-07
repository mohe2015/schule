
(var __-p-s_-m-v_-r-e-g)
(i "./push-state.lisp" "pushState")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(export
 (defun handle-fetch-error (error)
   (chain console (log (chain error)))
   (let ((status (chain error response status)))
     (if (= status 401)
         (let ((name
                (chain (one "#inputName")
                 (val (chain window local-storage name)))))
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

(export
 (defun handle-fetch-error-show (error)
   (chain console (log (chain error)))
   (let ((status (chain error response status)))
     (if (= status 401)
         (let ((name
                (chain (one "#inputName")
                 (val (chain window local-storage name)))))
           (chain window local-storage (remove-item "name"))
           (push-state "/login"
            (create last-url (chain window location href) last-state
             (chain window history state))))
         (if (= status 403)
             (let ((error-message
                    "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
               (chain (one "#errorMessage") (text error-message))
               (show-tab "#error"))
             (let ((error-message
                    (concatenate 'string "Unbekannter Fehler: "
                                 (chain error response status-text))))
               (chain (one "#errorMessage") (text error-message))
               (show-tab "#error")))))))

(export
 (defun check-status (response)
   (if (= (chain response status) 200)
       (chain -promise (resolve response))
       (let ((error (new (-error (chain response status-text)))))
         (setf (chain error response) response)
         (throw error)))))

(export
 (defun json (response)
   (if (not response)
       (throw (new (-error "No data"))))
   (chain response (json))))

(export (defun html () (chain response (text))))

(export
 (defun cache-then-network (url callback)
   (var networkdatareceived f)
   (var networkupdate
        (chain (fetch url) (then json)
         (then (lambda (data) (setf networkdatareceived t) (callback data)))))
   (chain caches (match url) (then json)
    (then
     (lambda (data)
       (if (not networkdatareceived)
           (callback data))))
    (catch (lambda () networkupdate)))))
