(defroute "/wiki/:name"
  (var pathname (chain window location pathname (split "/")))
  (show-tab "#loading")
  (chain ($ ".edit-button") (remove-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component (chain pathname 2))))
  (cleanup)
  
  (chain
   $
   (get
    (concatenate 'string "/api/wiki/" (chain pathname 2))
    (lambda (data)
      (chain ($ ".closable-badge") (remove))
      (chain ($ "#categories") (html ""))
      (if (chain data categories)
	  (loop for category in (chain data categories) do
	       (chain
		($ "#categories")
		(append
		 (who-ps-html
		  (:span :class "closable-badge" category))))
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
       (each
	(lambda ()
	  (chain -math-live (render-math-in-element this)))))
      (show-tab "#page")))
   (fail (lambda (jq-xhr text-status error-thrown)
	   (if (= error-thrown "Not Found")
	       (show-tab "#not-found")
	       (handle-error error-thrown T)))))) 
