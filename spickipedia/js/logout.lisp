 (defroute "/logout"
  (chain ($ ".edit-button") (add-class "disabled"))
  (show-tab "#loading")
  (chain $ (post "/api/logout" (create csrf_token (read-cookie "CSRF_TOEN"))
		 (lambda (data)
		   (chain window local-storage (remove-item "name"))
		   (replace-state "/login")))
	 (fail (lambda (jq-xhr text-status error-thrown)
		 (handle-error error-thrown T)))))

    (show-tab "#login")
    (chain ($ ".login-hide")
	   (fade-out
	    (lambda ()
	      (chain ($ ".login-hide") (attr "style" "display: none !important")))))
    (chain ($ ".navbar-collapse") (remove-class "show"))))
