(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./replace-state.lisp" "replaceState")

(defroute "/logout"
  (chain ($ ".edit-button") (add-class "disabled"))
  (show-tab "#loading")
  (chain $ (post "/api/logout" (create _csrf_token (read-cookie "_csrf_token"))
		 (lambda (data)
		   (chain window local-storage (remove-item "name"))
		   (replace-state "/login")))
	 (fail (lambda (jq-xhr text-status error-thrown)
		 (handle-error jq-xhr T)))))
