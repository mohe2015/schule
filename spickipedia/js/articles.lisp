(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./show-tab.lisp" "showTab")
(i "./handle-error.lisp" "handleError")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/articles" (show-tab "#loading")
 (get "/api/articles" t
      (chain data (sort (lambda (a b) (chain a (locale-compare b)))))
      (chain (one "#articles-list") (html ""))
      (loop for page in data
            do (let ((templ (one (chain (one "#articles-entry") (html)))))
                 (chain templ (find "a") (text page))
                 (chain templ (find "a")
                  (attr "href" (concatenate 'string "/wiki/" page)))
                 (chain (one "#articles-list") (append templ))))
      (show-tab "#articles")))
