(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./handle-error.lisp" "handleError")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(on ("submit" (one "#form-settings") event)
  (chain event (prevent-default))
  (chain (one "#new-category")
   (before
    (who-ps-html
     (:span :class "closable-badge bg-secondary"
      (:span :class "closable-badge-label" (chain (one "#new-category") (val)))
      (:button :type "button" :class "close close-tag" :aria-label "Close"
       (:span :aria-hidden "true" "&times;"))))))
  (chain (one "#new-category") (val "")))

(on ("click" (one "body") event :dynamic-selector ".close-tag")
  (chain (one this) (parent) (remove)))

(defroute "/tags/.rest" (show-tab "#loading")
 (chain console (log (chain rest (split "/"))))
 (chain $
  (post "/api/tags"
   (create _csrf_token (read-cookie "_csrf_token") tags
    (chain rest (split "/")))
   (lambda (data)
     (chain (one "#tags-list") (html ""))
     (if (not (null data))
         (progn
          (chain data (sort (lambda (a b) (chain a (locale-compare b)))))
          (loop for page in data
                do (let ((templ (one (chain (one "#articles-entry") (html)))))
                     (chain templ (find "a") (text page))
                     (chain templ (find "a")
                      (attr "href" (concatenate 'string "/wiki/" page)))
                     (chain (one "#tags-list") (append templ))))))
     (show-tab "#tags")))
  (fail (lambda (jq-xhr text-status error-thrown) (handle-error jq-xhr t)))))
