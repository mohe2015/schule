(setf (chain window onerror) (lambda (message source lineno colno error)
			   (alert (concatenate 'string "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! " message " source: " source " lineno: " lineno " colno: " colno " error: " error))))

(chain
 ($ "body")
 (on "click" ".history-pushState"
     (lambda (e)
       (chain e (prevent-default))
       (chain window history (push-state nil nil (chain ($ this) (data "href"))))
       (update-state)
       F)))

(chain
 ($ "#refresh")
 (click (lambda (e)
	  (chain e (prevent-default))
	  (update-state)
	  F)))

(defun handle-error (thrown-error show-error-page)
  (if (= thrown-error "Authorization Required")
      (let ((name (chain ($ "#inputName") (val (chain window local-storage name)))))
	(chain window local-storage (remove-item "name"))
	(chain window history (push-state (create last-url (chain window location href) last-state (chain window history state)) nil "/login"))
	(update-state))
      (if (= thrown-error "Forbidden")
	  (let ((error-message "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
	    (chain ($ "#errorMessage") (text error-message))
	    (if show-error-page
		(progn
		  (chain ($ "#errorMessage") (text error-message))
		  (show-tab "#error"))
		(alert error-message)))
	  (let ((error-message (concatenate 'string "Unbekannter Fehler: " thrown-error)))
	    (if show-error-page
		(progn
		  (chain ($ "#errorMessage") (text error-message))
		  (show-tab "#error"))
		(alert error-message))))))

(defun set-fullscreen (value)
  (if (and value (= (chain ($ ".fullscreen") length) 0))
      (chain ($ "article") (summernote "fullscreen.toggle"))
      (if (and (not value) (= (chain ($ ".fullscreen") length) 1))
	  (chain ($ "article") (summernote "fullscreen.toggle")))))

(defparameter finished-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "<i class=\"fa fa-check\"/>"
	tooltip "Fertig"
	click
	(lambda ()
	  (chain
	   ($ "#publish-changes-modal")
	   (on "shown.bs.modal"
	       (lambda ()
		 (chain ($ "#change-summary") (trigger "focus")))))
	  (chain ($ "#publish-changes-modal") (modal "show"))))))
     (render))))

(defparameter cancel-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "<i class=\"fa fa-times\"/>"
	tooltip "Abbrechen"
	click
	(lambda ()
	  (if (confirm "Möchtest du die Änderung wirklich verwerfen?")
	      (chain window history (back)))))))
     (render))))

(defparameter wiki-link-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "S"
	tooltip "Spickipedia-Link einfügen"
	click
	(lambda ()
	  (chain
	   ($ "#spickiLinkModal")
	   (on "shown.bs.modal"
	       (lambda ()
		 (chain ($ "#article-link-title") (trigger "focus")))))
	  (chain ($ "#spickiLinkModal") (modal "show"))))))
     (render))))

(defun read-cookie (name)
  (let ((name-eq (concatenate 'string name "="))
	(ca (chain document cookie (split ";"))))
    (loop for c in ca do
	 (if (chain c (trim) (starts-with name-eq))
	     (return (chain c (substring (chain name-eq length))))))))


(chain
 ($ "#publish-changes")
 (click
  (lambda ()
    (chain ($ "#publish-changes") (hide))
    (chain ($ "#publishing-changes") (show))

    (let ((change-summary (chain ($ "#change-summary") (val)))
	  (temp-dom (chain ($ "<output>") (append (chain $ (parse-h-t-m-l (chain ($ "article") (summernote "code"))))))))
      nil
    ))))
