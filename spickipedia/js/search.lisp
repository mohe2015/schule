(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "/js/template.lisp" "getTemplate")
(i "/js/fetch.lisp" "checkStatus" "json" "handleFetchErrorShow" "cacheThenNetwork")

(on ("input" (one "#search-query") event)
  (chain (one "#button-search") (click)))

(defroute "/search"
  (add-class (all ".edit-button") "disabled")
  (show-tab "#search"))

(defroute "/search/:query"
  (add-class (all ".edit-button") "disabled")
  (show-tab "#search")
  (setf (value (one "#search-query")) query))

(defun handle-response (data)
  (chain (one "#search-results-content") (html ""))
  (let ((results-contain-query f))
    (if (not (null data))
        (loop for page in data
              do (if (= (chain page title) query)
                     (setf results-contain-query t)
                     (let ((template (get-template "search-result-template")))
                        (setf (inner-text (one ".s-title" template)) (chain page title))
                        (setf (href template) (concatenate 'string "/wiki/" (chain page title)))
                        (setf (inner-html (one ".search-result-summary" template)) (chain page summary))
                        (append (one "#search-results-content") template)))))
    (if results-contain-query
        (chain (one "#no-search-results") (hide))
        (chain (one "#no-search-results") (show)))
    (chain (one "#search-results-loading") (stop) (hide))
    (chain (one "#search-results") (stop) (show))))

(on ("click" (one "#button-search") event)
  (let ((query (value (one "#search-query"))))
    (setf (href (one "#search-create-article")) (concatenate 'string "/wiki/" query "/create"))
    (chain window history (replace-state nil nil (concatenate 'string "/search/" query)))
    (hide (one "#search-results-loading"))
    (show (one "#search-results"))
    (if (not (undefined (chain window search-xhr))) ;; TODO fixme (maybe websocket at later point?)
        (chain window search-xhr (abort)))
    (cache-then-network (concatenate 'string "/api/search/" query) handle-response)))
