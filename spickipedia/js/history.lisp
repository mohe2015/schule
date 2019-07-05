
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(i "./push-state.lisp" "pushState") 
(i "./show-tab.lisp" "showTab") 
(i "./cleanup.lisp" "cleanup") 
(i "./math.lisp" "renderMath") 
(i "./handle-error.lisp" "handleError") 
(i "./fetch.lisp" "checkStatus" "json" "html" "handleFetchError") 
(chain ($ "#show-history")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/history")
       (chain window history state))
      f)))) 
(defroute "/wiki/:name/history"
          (chain ($ ".edit-button") (remove-class "disabled"))
          (show-tab "#loading")
          (var pathname (chain window location pathname (split "/")))
          (chain
           (fetch (concatenate 'string "/api/history/" (chain pathname 2)))
           (then check-status) (then json)
           (then
            (lambda (data)
              (chain ($ "#history-list") (html ""))
              (loop for page in data
                    do (let ((template
                              ($ (chain ($ "#history-item-template") (html)))))
                         (chain template (find ".history-username")
                          (text (chain page user)))
                         (chain template (find ".history-date")
                          (text (new (-date (chain page created)))))
                         (chain template (find ".history-summary")
                          (text (chain page summary)))
                         (chain template (find ".history-characters")
                          (text (chain page size)))
                         (chain template (find ".history-show")
                          (attr "href"
                           (concatenate 'string "/wiki/" (chain pathname 2)
                                        "/history/" (chain page id))))
                         (chain template (find ".history-diff")
                          (attr "href"
                           (concatenate 'string "/wiki/" (chain pathname 2)
                                        "/history/" (chain page id)
                                        "/changes")))
                         (chain ($ "#history-list") (append template))))
              (show-tab "#history"))))) 
(defroute "/wiki/:page/history/:id" (show-tab "#loading")
          (chain ($ ".edit-button") (remove-class "disabled")) (cleanup)
          (chain ($ "#wiki-article-title")
           (text (decode-u-r-i-component page)))
          (chain $
           (get (concatenate 'string "/api/revision/" id)
                (lambda (data)
                  (chain ($ "#currentVersionLink")
                   (attr "href" (concatenate 'string "/wiki/" page)))
                  (chain ($ "#is-outdated-article") (remove-class "d-none"))
                  (chain ($ "#categories") (html ""))
                  (loop for category in (chain data categories)
                        do (chain ($ "#categories")
                            (append
                             (who-ps-html
                              (:span :class "closable-badge bg-secondary"
                               category)))))
                  (chain ($ "article") (html (chain data content)))
                  (chain window history
                   (replace-state (create content data) nil nil))
                  (render-math)
                  (show-tab "#page")))
           (fail
            (lambda (jq-xhr text-status error-thrown)
              (if (= (chain jq-xhr status) 404)
                  (show-tab "#not-found")
                  (handle-error jq-xhr t)))))) 
(defroute "/wiki/:page/history/:id/changes"
          (chain ($ ".edit-button") (add-class "disabled"))
          (chain ($ "#currentVersionLink")
           (attr "href" (concatenate 'string "/wiki/" page)))
          (chain ($ "#is-outdated-article") (remove-class "d-none")) (cleanup)
          (var current-revision nil) (var previous-revision nil)
          (chain $
           (get (concatenate 'string "/api/revision/" id)
                (lambda (data)
                  (setf current-revision data)
                  (chain $
                   (get (concatenate 'string "/api/previous-revision/" id)
                        (lambda (data)
                          (setf previous-revision data)
                          (var diff-html
                           (htmldiff (chain previous-revision content)
                            (chain current-revision content)))
                          (chain ($ "article") (html diff-html))
                          (let* ((pt (chain previous-revision categories))
                                 (ct (chain current-revision categories))
                                 (both
                                  (chain pt
                                   (filter
                                    (lambda (x) (chain ct (includes x))))))
                                 (removed
                                  (chain pt
                                   (filter
                                    (lambda (x)
                                      (not (chain ct (includes x)))))))
                                 (added
                                  (chain ct
                                   (filter
                                    (lambda (x)
                                      (not (chain pt (includes x))))))))
                            (chain ($ "#categories") (html ""))
                            (loop for category in both
                                  do (chain ($ "#categories")
                                      (append
                                       (who-ps-html
                                        (:span :class
                                         "closable-badge bg-secondary"
                                         category)))))
                            (loop for category in removed
                                  do (chain ($ "#categories")
                                      (append
                                       (who-ps-html
                                        (:span :class
                                         "closable-badge bg-danger"
                                         category)))))
                            (loop for category in added
                                  do (chain ($ "#categories")
                                      (append
                                       (who-ps-html
                                        (:span :class
                                         "closable-badge bg-success"
                                         category)))))
                            (show-tab "#page"))))
                   (fail
                    (lambda (jq-xhr text-status error-thrown)
                      (if (= (chain jq-xhr status) 404)
                          (show-tab "#not-found")
                          (handle-error jq-xhr t)))))))
           (fail
            (lambda (jq-xhr text-status error-thrown)
              (if (= (chain jq-xhr status) 404)
                  (show-tab "#not-found")
                  (handle-error jq-xhr t)))))) 