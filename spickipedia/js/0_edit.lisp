

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
	    (chain ($ ".closable-badge") (remove))
	    (if (chain data categories)
		(loop for category in (chain data categories) do
		     (chain
		      ($ "#new-category")
		      (before
		       (who-ps-html
			(:span :class "closable-badge"
			       (:span :class "closable-badge-label" category)
			       (:button :type "button" :class "close close-tag" :aria-label "Close"
					(:span :aria-hidden "true" "&times;"))))))))
	    (chain ($ "article") (html (chain data content)))
	    (chain
	     ($ ".formula")
	     (each (lambda ()
		     (chain -math-live (render-math-in-element this)))))
	    (chain window history (replace-state (create content data) nil nil))
	    (show-editor)
	    (show-tab "#page")))
	 (fail
	  (lambda (jq-xhr text-status error-thrown)
	    (if (= error-thrown "Not Found")
		(show-tab "#not-found")
		(handle-error error-thrown T))))))))
