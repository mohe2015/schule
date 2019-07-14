(var __-p-s_-m-v_-r-e-g)

(i "./template.lisp" "getTemplate")
(i "./show-tab.lisp" "showTab")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchErrorShow" "cacheThenNetwork")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./state-machine.lisp" "enterState")

(defun update-page (data)
  (if (chain data categories)
      (loop for category in (chain data categories) do
        (let ((template (get-template "template-readonly-category")))
          (setf (inner-html (one ".closable-badge" template)) category)
          (append (one "#categories") template))))
  (setf (inner-html (one "article")) (chain data content))
  (show-tab "#page"))

(defroute "/wiki/:name"
  (enter-state "handleWikiName"))

(export
  (defun handle-wiki-name-enter (page)
    (var name (chain window location pathname (split "/") 2)) ;; TODO cleanup

    (remove-class (one ".edit-button") "disabled")
    (setf (inner-text (one "#wiki-article-title")) (decode-u-r-i-component name))
    (show-tab "#loading")

    (cache-then-network (concatenate 'string "/api/wiki/" name) update-page)))

(setf (chain window states) (or (chain window states) (new (-object))))
(setf (@ window 'states "handleWikiNameEnter") (lisp (make-symbol "handle-wiki-name-enter")))
