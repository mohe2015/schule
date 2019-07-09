(var __-p-s_-m-v_-r-e-g)


(i "./push-state.lisp" "pushState")
(i "./editor.lisp" "showEditor")
(i "./show-tab.lisp" "showTab")
(i "./utils.lisp" "all" "one" "clearChildren")

(defroute "/wiki/:name/create"
  (add-class (one ".edit-button") "disabled")
  (add-class (one "#is-outdated-article") "d-none")
  (if (and (not (null (chain window history state)))
           (not (null (chain window history state content))))
      (setf (inner-html (one "article")) (chain window history state content))
      (setf (inner-html (one "article")) ""))
  (show-editor)
  (show-tab "#page"))

(on ("click" (one "#create-article") event)
  (chain event (prevent-default))
  (let ((pathname (chain window location pathname (split "/"))))
    (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/create")
     (chain window history state))
    f))
