
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./push-state.lisp" "pushState")
(i "./show-tab.lisp" "showTab")
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun handle-error (response show-error-page)
   (let ((status (chain response status)))
     (if (= status 401)
         (progn
           (setf (value (one "#inputName")) (chain window local-storage name))
           (chain window local-storage (remove-item "name"))
           (push-state "/login"
            (create last-url (chain window location href) last-state
             (chain window history state))))
         (if (= status 403)
             (let ((error-message
                    "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
               (chain (one "#errorMessage") (text error-message))
               (if show-error-page
                   (progn
                    (chain (one "#errorMessage") (text error-message))
                    (show-tab "#error"))
                   (alert error-message)))
             (let ((error-message
                    (concatenate 'string "Unbekannter Fehler: "
                                 (chain response status-text))))
               (if show-error-page
                   (progn
                    (chain (one "#errorMessage") (text error-message))
                    (show-tab "#error"))
                   (alert error-message))))))))
