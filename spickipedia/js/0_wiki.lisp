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
      (chain ($ "article") (html data))
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
