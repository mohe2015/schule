(chain
 ($ "#publish-changes")
 (click
  (lambda ()
    (chain ($ "#publish-changes") (hide))
    (chain ($ "#publishing-changes") (show))

    (let ((change-summary (chain ($ "#change-summary") (val)))
	  (temp-dom (chain ($ "article") (clone)))
	  (article-path (chain window location pathname (split "/") 2)))
      (revert-math temp-dom)
      (setf categories (chain
			($ "#settings-modal")
			(find ".closable-badge-label")
			(map
			 (lambda ()
			   (chain this inner-text)))
			(get)))
      
      (chain $ (post (concatenate 'string "/api/wiki/" article-path) (create
								summary change-summary
								html (chain temp-dom (html))
								categories categories
								_csrf_token (read-cookie 
									     "_csrf_token"))
		     (lambda (data)
		       (push-state article-path)))
	     (fail (lambda (jq-xhr text-status error-thrown)
		     (chain ($ "#publish-changes") (show))
		     (chain ($ "#publishing-changes") (hide))
		     (handle-error jq-xhr F))))
      ))))


(defun show-editor ()
  nil)

(defun hide-editor ()
  nil)
