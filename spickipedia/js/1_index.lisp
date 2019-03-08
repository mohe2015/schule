(setf (chain window onerror) (lambda (message source lineno colno error)
			   (alert (concatenate 'string "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! " message " source: " source " lineno: " lineno " colno: " colno " error: " error))))

(chain
 ($ "body")
 (on "click" ".history-pushState"
     (lambda (e)
       (chain e (prevent-default))
       (push-state (chain ($ this) (attr "href")))
       F)))

(chain
 ($ "#refresh")
 (click (lambda (e)
	  (chain e (prevent-default))
	  (update-state)
	  F)))

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
		  (alert error-message)))))))

(defun read-cookie (name)
  (let ((name-eq (concatenate 'string name "="))
	(ca (chain document cookie (split ";"))))
    (loop for c in ca do
	 (if (chain c (trim) (starts-with name-eq))
	     (return (chain c (trim) (substring (chain name-eq length))))))))

(defun cleanup ()
  (chain ($ "#publish-changes-modal") (modal "hide"))
  (chain ($ "#publish-changes") (show))
  (chain ($ "#publishing-changes") (hide)))

(defun show-tab (id)
  (chain ($ ".my-tab") (not id) (fade-out))
  (chain ($ id) (fade-in)))

(defun get-url-parameter (param)
  (let* ((page-url (chain window location search (substring 1)))
	(url-variables (chain page-url (split "&"))))
    (loop for parameter-name in url-variables do
	 (setf parameter-name (chain parameter-name (split "=")))
	 (if (= (chain parameter-name 0) param)
	     (return (chain parameter-name 1))))))

(defun replace-state (url data)
  (chain window history (replace-state data nil url))
  (update-state))

(defun push-state (url data)
  (chain window history (push-state data nil url))
  (update-state))

(defroute "/"
  (chain ($ ".edit-button") (remove-class "disabled"))
  (replace-state "/wiki/Hauptseite"))

(setf
 (chain window onpopstate)
 (lambda (event)
   (if (chain window last-url)
       (let ((pathname (chain window last-url (split "/"))))
	 (if (and (= (chain pathname length) 4) (= (chain pathname 1) "wiki") (or (= (chain pathname 3) "create") (= (chain pathname 3) "edit")))
	     (progn
	       (if (confirm "Möchtest du die Änderung wirklich verwerfen?")
		   (update-state))
	       (return)))))
   (update-state)))

(setf
 (chain window onbeforeunload)
 (lambda ()
   (let ((pathname (chain window location pathname (split "/"))))
     (if (and (= (chain pathname length) 4) (= (chain pathname 1) "wiki") (or (= (chain pathname 3) "create") (= (chain pathname 3) "edit")))
	 T)))) ;; TODO this method is not allowed to return anything if not canceling

(lisp *UPDATE-STATE*)

(setf
  (chain window onload)
  (lambda ()
    (update-state)))
