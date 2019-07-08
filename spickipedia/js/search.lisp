(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./show-tab.lisp" "showTab")
(i "./handle-error.lisp" "handleError")
(i "./utils.lisp" "all" "one" "clearChildren")

(on ("input" (one "#search-query") event)
  (chain (one "#button-search") (click)))

(defroute "/search" (chain (one ".edit-button") (add-class "disabled"))
 (show-tab "#search"))

(defroute "/search/:query" (chain (one ".edit-button") (add-class "disabled"))
 (show-tab "#search") (chain (one "#search-query") (val query)))

(on ("click" (one "#button-search") event)
  (let ((query (chain (one "#search-query") (val))))
    (chain (one "#search-create-article")
     (attr "href" (concatenate 'string "/wiki/" query "/create")))
    (chain window history
     (replace-state nil nil (concatenate 'string "/search/" query)))
    (chain (one "#search-results-loading") (stop) (show))
    (chain (one "#search-results") (stop) (hide))
    (if (not (undefined (chain window search-xhr)))
        (chain window search-xhr (abort)))
    (setf (chain window search-xhr)
          (chain $
           (get (concatenate 'string "/api/search/" query)
                (lambda (data)
                  (chain (one "#search-results-content") (html ""))
                  (let ((results-contain-query f))
                    (if (not (null data))
                        (loop for page in data
                              do (if (= (chain page title) query)
                                     (setf results-contain-query t)) (let ((template
                                                                            (one
                                                                             (chain
                                                                              (one
                                                                               "#search-result-template")
                                                                              (html)))))
                                                                       (chain
                                                                        template
                                                                        (find
                                                                         ".s-title")
                                                                        (text
                                                                         (chain
                                                                          page
                                                                          title)))
                                                                       (chain
                                                                        template
                                                                        (attr
                                                                         "href"
                                                                         (concatenate
                                                                          'string
                                                                          "/wiki/"
                                                                          (chain
                                                                           page
                                                                           title))))
                                                                       (chain
                                                                        template
                                                                        (find
                                                                         ".search-result-summary")
                                                                        (html
                                                                         (chain
                                                                          page
                                                                          summary)))
                                                                       (chain
                                                                        (one
                                                                         "#search-results-content")
                                                                        (append
                                                                         template)))))
                    (if results-contain-query
                        (chain (one "#no-search-results") (hide))
                        (chain (one "#no-search-results") (show)))
                    (chain (one "#search-results-loading") (stop) (hide))
                    (chain (one "#search-results") (stop) (show)))))
           (fail
            (lambda (jq-xhr text-status error-thrown)
              (if (not (= text-status "abort"))
                  (handle-error jq-xhr t))))))))
