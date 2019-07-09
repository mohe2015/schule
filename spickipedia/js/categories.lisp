(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./template.lisp" "getTemplate")

(on ("submit" (one "#form-settings") event)
  (chain event (prevent-default))
  (let ((template (get-template "template-category")))
    (setf (inner-html (one ".closable-badge-label" template inner-text)) (value (one "#new-category")))
    (before (one "#new-category") template))
  (setf (value (one "#new-category")) ""))

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
                     (chain templ (query-selector "a") (text page))
                     (chain templ (query-selector "a")
                      (attr "href" (concatenate 'string "/wiki/" page)))
                     (chain (one "#tags-list") (append templ))))))
     (show-tab "#tags")))
  (fail (lambda (jq-xhr text-status error-thrown) (handle-error jq-xhr t)))))
