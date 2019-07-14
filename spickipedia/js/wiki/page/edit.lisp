(var __-p-s_-m-v_-r-e-g)

(i "/js/cleanup.lisp" "cleanup")
(i "/js/show-tab.lisp" "showTab")
(i "/js/math.lisp" "renderMath")
(i "/js/editor.lisp" "showEditor" "hideEditor")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/fetch.lisp" "checkStatus" "json" "handleFetchErrorShow" "cacheThenNetwork")
(i "/js/template.lisp" "getTemplate")
(i "/js/state-machine.lisp" "enterState" "pushState")

(on ("click" (all ".edit-button") event)
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((pathname (chain window location pathname (split "/"))))
    (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/edit") (chain window history state)))
  f)

(defun init-editor (data)
  ;;(chain window history (replace-state data nil nil))
  (when (chain data categories)
    (remove (all ".closable-badge" (one "#form-settings")))
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

  (show-tab "#loading")
  (cache-then-network (concatenate 'string "/api/wiki/" page) init-editor))

(defstate handle-wiki-page-edit-enter
  (add-class (one ".edit-button") "disabled"))

(defstate handle-wiki-page-edit-exit
  (remove-class (one ".edit-button") "disabled")
  (hide-editor))
