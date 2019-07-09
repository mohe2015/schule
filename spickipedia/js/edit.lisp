(var __-p-s_-m-v_-r-e-g)

(i "./push-state.lisp" "pushState")
(i "./cleanup.lisp" "cleanup")
(i "./show-tab.lisp" "showTab")
(i "./math.lisp" "renderMath")
(i "./editor.lisp" "showEditor")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchError")

(on ("click" (all ".edit-button") event)
  (chain event (prevent-default))
  (let ((pathname (chain window location pathname (split "/"))))
    (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/edit") (chain window history state))))

(defun init-editor (data)
  (chain (all ".closable-badge") (remove))
  (if (chain data categories)
      (loop for category in (chain data categories)
            do (chain (one "#new-category")
                (before
                 (who-ps-html
                  (:span :class "closable-badge bg-secondary"
                   (:span :class "closable-badge-label" category)
                   (:button :type "button" :class "close close-tag" :aria-label
                    "Close" (:span :aria-hidden "true" "&times;"))))))))
  (setf (inner-html (one "article")) (chain data content))
  (render-math)
  (show-editor)
  (show-tab "#page"))

(defroute "/wiki/:name/edit"
 (add-class (one ".edit-button") "disabled")
 (add-class (one "#is-outdated-article") "d-none")
 (setf (inner-text (one "#wiki-article-title")) (decode-u-r-i-component name))
 (cleanup)
 (if (not (null (chain window history state)))
     (init-editor (chain window history state))
     (progn
      (show-tab "#loading")
      (chain
        (fetch (concatenate 'string "/api/wiki/" name))
        (then check-status)
        (then json)
        (then
          (lambda (data)
            (init-editor data)
            (chain window history (replace-state data nil nil))))
        (catch
          (lambda (error)
            (if (= (chain error response status) 404)
                (show-tab "#not-found")
                (handle-fetch-error error))))))))
