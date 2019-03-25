(var __-p-s_-m-v_-r-e-g)

(import "./push-state.lisp" "pushState")
(import "./show-tab.lisp" "showTab")
(import "./cleanup.lisp" "cleanup")
(import "./math.lisp" "renderMath")

(chain
 ($ "#show-history")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/history") (chain window history state))
      F)))) 

(defroute "/wiki/:name/history"
  (chain ($ ".edit-button") (remove-class "disabled"))
  (show-tab "#loading")
  (var pathname (chain window location pathname (split "/")))
  (get (concatenate 'string "/api/history/" (chain pathname 2)) T
       (chain ($ "#history-list") (html ""))
       (loop for page in data do
	    (let ((template ($ (chain ($ "#history-item-template") (html)))))
	      (chain template (find ".history-username") (text (chain page user)))
	      (chain template (find ".history-date") (text (new (-Date (chain page created)))))
	      (chain template (find ".history-summary") (text (chain page summary)))
	      (chain template (find ".history-characters") (text (chain page size)))
	      (chain template (find ".history-show") (attr "href" (concatenate 'string "/wiki/" (chain pathname 2) "/history/" (chain page id))))
	      (chain template (find ".history-diff") (attr "href" (concatenate 'string "/wiki/" (chain pathname 2) "/history/" (chain page id) "/changes")))
	      (chain ($ "#history-list") (append template))))
       (show-tab "#history")))

(defroute "/wiki/:page/history/:id"
  (show-tab "#loading")
  (chain ($ ".edit-button") (remove-class "disabled"))
  (cleanup)
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component page)))
  (chain
   $
   (get
    (concatenate 'string "/api/revision/" id)
    (lambda (data)
      (chain ($ "#currentVersionLink") (attr "href" (concatenate 'string "/wiki/" page)))
      (chain ($ "#is-outdated-article") (remove-class "d-none"))
      (chain ($ "article") (html data))
      (chain window history (replace-state (create content data) nil nil))
      (render-math)
      (show-tab "#page")
      ))
   (fail
    (lambda (jq-xhr text-status error-thrown)
      (if (= (chain jq-xhr status) 404)
	  (show-tab "#not-found")
	  (handle-error jq-xhr T))))))

(defroute "/wiki/:page/history/:id/changes"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#currentVersionLink") (attr "href" (concatenate 'string "/wiki/" page)))
  (chain ($ "#is-outdated-article") (remove-class "d-none"))
  (cleanup)
  (var current-revision nil)
  (var previous-revision nil)
  (chain
   $
   (get
    (concatenate 'string "/api/revision/" id)
    (lambda (data)
      (setf current-revision data)
      (chain
       $
       (get
	(concatenate 'string "/api/previous-revision/" id)
	(lambda (data)
	  (setf previous-revision data)
	  (var diff-html (htmldiff previous-revision current-revision))
	  (chain ($ "article") (html diff-html))
	  (show-tab "#page")))
       (fail
	(lambda (jq-xhr text-status error-thrown)
	  (if (= (chain jq-xhr status) 404)
	      (show-tab "#not-found")
	      (handle-error jq-xhr T)))))))
   (fail
    (lambda (jq-xhr text-status error-thrown)
      (if (= (chain jq-xhr status) 404)
	  (show-tab "#not-found")
	  (handle-error jq-xhr T))))))
