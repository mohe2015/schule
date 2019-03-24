(export 1)

(export "test")

(export (defun test () nil))

(import "./test.mjs" "jo")

(defroute "/articles"
   (show-tab "#loading")
   (get "/api/articles" T
	(chain data (sort (lambda (a b)
			    (chain a (locale-compare b)))))
	(chain ($ "#articles-list") (html ""))
	(loop for page in data do
	     (let ((templ ($ (chain ($ "#articles-entry") (html)))))
	       (chain templ (find "a") (text page))
	       (chain templ (find "a") (attr "href" (concatenate 'string "/wiki/" page)))
	       (chain ($ "#articles-list") (append templ))))
	(show-tab "#articles"))) 
