(var __-p-s_-m-v_-r-e-g)

(i "./push-state.lisp" "pushState")
(i "./show-tab.lisp" "showTab")

(export
 (defun handle-error (jq-xhr show-error-page)
   (let ((status (chain jq-xhr status)))
     (if (= status 401)
	 (let ((name (chain ($ "#inputName") (val (chain window local-storage name)))))
	   (chain window local-storage (remove-item "name"))
	   (push-state "/login" (create last-url (chain window location href) last-state (chain window history state))))
	 (if (= jq-xhr 403)
	     (let ((error-message "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
	       (chain ($ "#errorMessage") (text error-message))
	       (if show-error-page
		   (progn
		     (chain ($ "#errorMessage") (text error-message))
		     (show-tab "#error"))
		   (alert error-message)))
	     (let ((error-message (concatenate 'string "Unbekannter Fehler: " (chain jq-xhr status-text))))
	       (if show-error-page
		   (progn
		     (chain ($ "#errorMessage") (text error-message))
		     (show-tab "#error"))
		   (alert error-message))))))))
