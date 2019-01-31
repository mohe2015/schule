

(chain
 ($ ".edit-button")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/edit") (chain window history state))
      F))))
      
(defroute "/wiki/:name/edit"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component name)))
  (cleanup)
  (if (and (not (null (chain window history state))) (not (null (chain window history state content))))
      (progn
	(chain ($ "article") (html (chain window history state content)))
	(chain ($ ".formula") (each (lambda ()
				      (chain -math-live (render-math-in-element this)))))
	(show-editor)
	(show-tab "#page"))
      (progn
	(show-tab "#loading")
	(chain
	 $
	 (get
	  (concatenate 'string "/api/wiki/" name)
	  (lambda (data)
	    (chain ($ "article") (html data))
	    (chain
	     ($ ".formula")
	     (each (lambda ()
		     (chain -math-live (render-math-element this)))))
	    (chain window history (replace-state (create content data) nil nil))
	    (show-editor)
	    (show-tab "#page")))
	 (fail
	  (lambda (jq-xhr text-status error-thrown)
	    (if (= error-thrown "Not Found")
		(show-tab "#not-found")
		(handle-error error-thrown T))))))))
