(var __-p-s_-m-v_-r-e-g)

(defroute "/wiki/:name/create"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))

  (if (and (not (null (chain window history state))) (not (null (chain window history state content))))
      (chain ($ "article") (html (chain window history state content)))
      (chain ($ "article") (html "")))
  (show-editor)
  (show-tab "#page"))
 


(chain
 ($ "#create-article")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/create") (chain window history state))
      F))))
