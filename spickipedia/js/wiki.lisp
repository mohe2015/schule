(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./show-tab.lisp" "showTab")
(i "./cleanup.lisp" "cleanup")
(i "./handle-error.lisp" "handleError")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")

(defun update-page (data)
  (chain ($ ".closable-badge") (remove))
  (chain ($ "#categories") (html ""))
  (if (chain data categories)
      (loop for category in (chain data categories) do
	   (chain
	    ($ "#categories")
	    (append
	     (who-ps-html
	      (:span :class "closable-badge bg-secondary" category))))
	   (chain
	    ($ "#new-category")
	    (before
	     (who-ps-html
	      (:span :class "closable-badge bg-secondary"
		     (:span :class "closable-badge-label" category)
		     (:button :type "button" :class "close close-tag" :aria-label "Close"
			      (:span :aria-hidden "true" "&times;"))))))))
  (chain ($ "article") (html (chain data content)))      
  (render-math))

(defroute "/wiki/:name"
    (var pathname (chain window location pathname (split "/")))
  (chain ($ ".edit-button") (remove-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component (chain pathname 2))))
  (cleanup)

  (var network-data-received F)
  (show-tab "#loading")

  ;; fetch fresh data
  (var
   network-update
   (chain (fetch (concatenate 'string "/api/wiki/" (chain pathname 2)))
	  (then (lambda (response)
		  (chain response (json))))
	  (then (lambda (data)
		  (setf network-data-received T)
		  (update-page data)))))
  
  ;; fetch cached data
  (chain
   caches
   (match (concatenate 'string "/api/wiki/" (chain pathname 2)))
   (then (lambda (response)
	   (if (not response)
	       (throw (-error "No data"))) ;; is that right syntax?
	   (chain response (json))))
   (then (lambda (data)
	   ;; don't overwrite newer network data
	   (if (not network-data-received)
	       (update-page data))))
   (catch (lambda ()
	    ;; we didn't get cached data, the network is our last hope
	    network-update))
   (catch (lambda (jq-xhr text-status error-thrown)
	    (if (= (chain jq-xhr status) 404)
		(show-tab "#not-found")
		(handle-error jq-xhr T))))
   (then (lambda ()
	   ;; stop spinner
	   (show-tab "#page")))))
