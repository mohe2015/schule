
(defroute "/login"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#publish-changes-modal") (modal "hide"))
  (let ((url-username (get-url-parameter "username"))
	(url-password (get-url-parameter "password")))
    (if (and (not (undefined url-username)) (not (undefined url-password)))
	(progn
	  (chain ($ "#inputName") (val (decode-u-r-i-component url-username)))
	  (chain ($ "#inputPassword") (val (decode-u-r-i-component url-password))))
	(if (not (undefined (chain window local-storage name)))
	    (progn
	      (replace-state "/wiki/Hauptseite")
	      (return))))))
 

(chain
 ($ "#login-form")
 (on "submit"
     (lambda (e)
     (chain e (prevent-default))
       (chain ($ "#login-button") (prop "disabled" T) (html "<span class=\"spinner-border spinner-border-sm\" role=\"status\" aria-hidden=\"true\"></span> Anmelden..."))

       (login-post F))))
     
(defun login-post (repeated)
  (let ((name (chain ($ "#inputName") (val)))
	(password (chain ($ "#inputPassword") (val))))
    (chain
     $
     (post
      "/api/login"
      (create
       csrf_token (read-cookie "CSRF_TOKEN")
       name name
       password password)
      (lambda (data)
	(chain ($ "#login-button") (prop "disabled" F) (html "Anmelden"))
	(chain ($ "#inputPassword") (val ""))
	(setf (chain window local-storage name) name)
	(if (and (not (null (chain window history state)))
		 (not (undefined (chain window history state last-state)))
		 (not (undefined (chain window history state last-url))))
	    (replace-state (chain window history state last-url) (chain window history state last-state))
	    (replace-state "/wiki/Hauptseite"))))
     (fail
      (lambda (jq-xhr text-status error-thrown)
	(chain window local-storage (remove-item "name"))
	(if (= error-thrown "Forbidden")
	    (if repeated
		(progn
		  (alert "Ungültige Zugansdaten!")
		  (chain ($ "#login-button") (prop "disabled" F) (html "Anmelden")))
		(login-post T))
	    (handle-error error-thrown T)))))))
