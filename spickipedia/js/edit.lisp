(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./push-state.lisp" "pushState")
(i "./cleanup.lisp" "cleanup")
(i "./show-tab.lisp" "showTab")
(i "./math.lisp" "renderMath")
(i "./editor.lisp" "showEditor")
(i "./handle-error.lisp" "handleError")

(chain
 ($ ".edit-button")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/edit") (chain window history state))
      F))))

(defun init-editor (data)
  (chain ($ ".closable-badge") (remove))
  (if (chain data categories)
      (loop for category in (chain data categories) do
       (chain
        ($ "#new-category")
        (before
         (who-ps-html
          (:span :class "closable-badge bg-secondary"
             (:span :class "closable-badge-label" category)
             (:button :type "button" :class "close close-tag" :aria-label "Close"
                  (:span :aria-hidden "true" "&times;"))))))))
  (chain ($ "article") (html (chain data content)))
  (render-math)
  (show-editor)
  (show-tab "#page"))

(defroute "/wiki/:name/edit"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component name)))
  (cleanup)
  (if (not (null (chain window history state)))
      (init-editor (chain window history state))
      (progn
       (show-tab "#loading")
       (chain
        $
        (get
         (concatenate 'string "/api/wiki/" name)
         (lambda (data)
           (init-editor data)
           (chain window history (replace-state data nil nil))))
        (fail
         (lambda (jq-xhr text-status error-thrown)
           (if (= (chain jq-xhr status) 404)
            (show-tab "#not-found")
            (handle-error jq-xhr T))))))))
