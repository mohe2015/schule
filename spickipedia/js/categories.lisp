
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(i "./show-tab.lisp" "showTab") 
(i "./read-cookie.lisp" "readCookie") 
(i "./handle-error.lisp" "handleError") 
(chain ($ "#add-tag-form")
 (submit
  (lambda (e)
    (chain e (prevent-default))
    (chain ($ "#new-category")
     (before
      (who-ps-html
       (:span :class "closable-badge bg-secondary"
        (:span :class "closable-badge-label" (chain ($ "#new-category") (val)))
        (:button :type "button" :class "close close-tag" :aria-label "Close"
         (:span :aria-hidden "true" "&times;"))))))
    (chain ($ "#new-category") (val ""))))) 
(chain ($ "body")
 (on "click" ".close-tag" (lambda (e) (chain ($ this) (parent) (remove))))) 
(defroute "/tags/.rest" (show-tab "#loading")
 (chain console (log (chain rest (split "/"))))
 (chain $
  (post "/api/tags"
   (create _csrf_token (read-cookie "_csrf_token") tags
    (chain rest (split "/")))
   (lambda (data)
     (chain ($ "#tags-list") (html ""))
     (if (not (null data))
         (progn
          (chain data (sort (lambda (a b) (chain a (locale-compare b)))))
          (loop for page in data
                do (let ((templ ($ (chain ($ "#articles-entry") (html)))))
                     (chain templ (find "a") (text page))
                     (chain templ (find "a")
                      (attr "href" (concatenate 'string "/wiki/" page)))
                     (chain ($ "#tags-list") (append templ))))))
     (show-tab "#tags")))
  (fail (lambda (jq-xhr text-status error-thrown) (handle-error jq-xhr t))))) 