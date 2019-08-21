(var __-p-s_-m-v_-r-e-g)


(i "/js/state-machine.lisp" "pushState")
(i "/js/editor.lisp" "showEditor")
(i "/js/show-tab.lisp" "showTab")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/state-machine.lisp" "enterState")

(defroute "/wiki/:name/create"
    ;; TODO clean up - here are lots of useless lines of code
    (enter-state "handleWikiPageEdit")
  (add-class (all ".edit-button") "disabled")
  (add-class (one "#is-outdated-article") "d-none")
  (if (and (not (null (chain window history state)))
           (not (null (chain window history state content))))
      (setf (inner-html (one "article")) (chain window history state content))
      (setf (inner-html (one "article")) ""))
  (show-editor)
  (show-tab "#page"))

(on ("click" (one "#create-article") event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/create")
		  (chain window history state))
      f))
