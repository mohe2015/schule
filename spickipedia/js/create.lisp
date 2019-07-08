(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./push-state.lisp" "pushState")
(i "./editor.lisp" "showEditor")
(i "./show-tab.lisp" "showTab")
(i "./utils.lisp" "all" "one" "clearChildren")

(defroute "/wiki/:name/create"
 (chain (one ".edit-button") (add-class "disabled"))
 (chain (one "#is-outdated-article") (add-class "d-none"))
 (if (and (not (null (chain window history state)))
          (not (null (chain window history state content))))
     (chain (one "article") (html (chain window history state content)))
     (chain (one "article") (html "")))
 (show-editor) (show-tab "#page"))

(on ("click" (one "#create-article") event)
  (chain event (prevent-default))
  (let ((pathname (chain window location pathname (split "/"))))
    (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/create")
     (chain window history state))
    f))
