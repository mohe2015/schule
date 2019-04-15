(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./handle-error.lisp" "handleError")

(chain
 ($ "#add-tag-form")
 (submit
  (lambda (e)
    (chain e (prevent-default))
    (chain
     ($ "#new-category")
     (before
      (who-ps-html
       (:span :class "closable-badge bg-secondary"
	      (:span :class "closable-badge-label" (chain ($ "#new-category") (val)))
	      (:button :type "button" :class "close close-tag" :aria-label "Close"
		       (:span :aria-hidden "true" "&times;"))))))
    (chain ($ "#new-category") (val "")))))

(chain
 ($ "body")
 (on
  "click"
  ".close-tag"
  (lambda (e)
    (chain ($ this) (parent) (remove)))))

(defroute "/tags/.rest"
  (show-tab "#loading")
  (chain console (log (chain rest (split "/"))))

  (chain $ (post "/api/tags"
		 (create _csrf_token (read-cookie "_csrf_token")
			 tags (chain rest (split "/")))
		 (lambda (data)
		   (chain console (log data))
		   ))
	 (fail (lambda (jq-xhr text-status error-thrown)
		 (handle-error jq-xhr T)))))
