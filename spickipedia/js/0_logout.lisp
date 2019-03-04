 (defroute "/logout"
  (chain ($ ".edit-button") (add-class "disabled"))
  (show-tab "#loading")
  (chain $ (post "/api/logout" (create _csrf_token (read-cookie "_csrf_token"))
		 (lambda (data)
		   (chain window local-storage (remove-item "name"))
		   (replace-state "/login")))
	 (fail (lambda (jq-xhr text-status error-thrown)
		 (handle-error error-thrown T)))))
