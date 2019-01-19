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
      (let ((name (chain ($ "#inputName") (val (chain window local-storage name))))
	    (state (create last-url (chain window location href))))
	(chain window local-storage (remove-item "name"))
	(chain window history (push-state (create a 1 b 2) nil "/login"))
	(update-state))))
