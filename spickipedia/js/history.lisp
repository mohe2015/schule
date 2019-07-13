
(var __-p-s_-m-v_-r-e-g)

(i "./push-state.lisp" "pushState")
(i "./show-tab.lisp" "showTab")
(i "./cleanup.lisp" "cleanup")
(i "./math.lisp" "renderMath")
(i "./fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./template.lisp" "getTemplate")

(on ("click" (one "#show-history") event)
  (chain event (prevent-default))
  (let ((pathname (chain window location pathname (split "/"))))
    (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/history")
     (chain window history state))
    f))

(defroute "/wiki/:name/history"
 (remove-class (one ".edit-button") "disabled")
 (show-tab "#loading")
 (chain (fetch (concatenate 'string "/api/history/" name))
  (then check-status) (then json)
  (then
   (lambda (data)
     (setf (inner-html (one "#history-list")) "")
     (loop for page in data
           do (let ((template (get-template "history-item-template")))
                (setf (inner-text (chain template (query-selector ".history-username"))) (chain page user))
                (setf (inner-text (chain template (query-selector ".history-date"))) (new (-date (chain page created))))
                (setf (inner-text (chain template (query-selector ".history-summary"))) (chain page summary))
                (setf (inner-text (chain template (query-selector ".history-characters"))) (chain page size))
                (setf (href (chain template (query-selector ".history-show"))) (concatenate 'string "/wiki/" name "/history/" (chain page id)))
                (setf (href (chain template (query-selector ".history-diff"))) (concatenate 'string "/wiki/" name "/history/" (chain page id) "/changes"))
                (chain (one "#history-list") (append template))))
     (show-tab "#history")))))

(defroute "/wiki/:page/history/:id"
  (show-tab "#loading")
  (remove-class (one ".edit-button") "disabled")
  (cleanup)
  (setf (inner-text (one "#wiki-article-title")) (decode-u-r-i-component page))
  (chain
    (fetch (concatenate 'string "/api/revision/" id))
    (then check-status)
    (then json)
    (then
      (lambda (data)
        (setf (href (one "#currentVersionLink")) (concatenate 'string "/wiki/" page))
        (remove-class (one "#is-outdated-article") "d-none")
        (setf (inner-html (one "#categories")) "")
        (loop for category in (chain data categories) do
          (let ((template (get-template "template-readonly-category")))
            (setf (inner-html (one ".closable-badge" template)) category)
            (append (one "#categories") template)))
        (setf (inner-html (one "article")) (chain data content))
        (chain window history (replace-state (create content data) nil nil))
        (render-math)
        (show-tab "#page")))
    (catch
      (lambda (error)
        (if (= (chain error response status) 404)
            (show-tab "#not-found")
            (handle-fetch-error error))))))

(defroute "/wiki/:page/history/:id/changes"
 (chain (one ".edit-button") (add-class "disabled"))
 (chain (one "#currentVersionLink")
  (attr "href" (concatenate 'string "/wiki/" page)))
 (chain (one "#is-outdated-article") (remove-class "d-none")) (cleanup)
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
                 (chain (one "article") (html diff-html))
                 (let* ((pt (chain previous-revision categories))
                        (ct (chain current-revision categories))
                        (both
                         (chain pt
                          (filter (lambda (x) (chain ct (includes x))))))
                        (removed
                         (chain pt
                          (filter (lambda (x) (not (chain ct (includes x)))))))
                        (added
                         (chain ct
                          (filter (lambda (x) (not (chain pt (includes x))))))))
                   (chain (one "#categories") (html ""))
                   (loop for category in both
                         do (chain (one "#categories")
                             (append
                              (who-ps-html
                               (:span :class "closable-badge bg-secondary"
                                category)))))
                   (loop for category in removed
                         do (chain (one "#categories")
                             (append
                              (who-ps-html
                               (:span :class "closable-badge bg-danger"
                                category)))))
                   (loop for category in added
                         do (chain (one "#categories")
                             (append
                              (who-ps-html
                               (:span :class "closable-badge bg-success"
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
