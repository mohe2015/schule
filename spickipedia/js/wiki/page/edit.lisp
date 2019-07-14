(var __-p-s_-m-v_-r-e-g)

(i "/js/push-state.lisp" "pushState")
(i "/js/cleanup.lisp" "cleanup")
(i "/js/show-tab.lisp" "showTab")
(i "/js/math.lisp" "renderMath")
(i "/js/editor.lisp" "showEditor" "hideEditor")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/fetch.lisp" "checkStatus" "json" "handleFetchErrorShow")
(i "/js/template.lisp" "getTemplate")
(i "/js/state-machine.lisp" "enterState")

;; TODO FIXME if lazy loading this would need to be loaded before
(on ("click" (all ".edit-button") event)
  (chain event (prevent-default))
  (let ((pathname (chain window location pathname (split "/"))))
    (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/edit") (chain window history state))))

(defun init-editor (data)
  (if (chain data categories)
      ;; TODO clear categories
      (loop for category in (chain data categories) do
        (let ((template (get-template "template-category")))
          (setf (inner-html (one ".closable-badge-label" template)) category)
          (before (one "#new-category") template))))
  (setf (inner-html (one "article")) (chain data content))
  (show-editor)
  (show-tab "#page"))

(defroute "/wiki/:page/edit"
  (enter-state "handleWikiPageEdit")
 (setf (inner-text (one "#wiki-article-title")) (decode-u-r-i-component page))

 (if (not (null (chain window history state)))
     (init-editor (chain window history state))
     (progn
      (show-tab "#loading")
      (chain
        (fetch (concatenate 'string "/api/wiki/" page))
        (then check-status)
        (then json)
        (then
          (lambda (data)
            (init-editor data)
            (chain window history (replace-state data nil nil))))
        (catch handle-fetch-error-show)))))

(defstate handle-wiki-page-edit-enter
  (add-class (one ".edit-button") "disabled"))

(defstate handle-wiki-page-edit-exit
  (remove-class (one ".edit-button") "disabled")
  (hide-editor))
