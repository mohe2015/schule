(chain
 ($ "#add-tag-form")
 (submit
  (lambda (e)
    (chain e (prevent-default))
    (chain
     ($ "#new-category")
     (before
      (who-ps-html
       (:span :class "closable-badge"
	      (:span :class "closable-badge-label" (chain ($ "#new-category") (val)))
	      (:button :type "button" :class "close close-tag" :aria-label "Close"
		       (:span :aria-hidden "true" "&times;"))))))
    (chain ($ "#new-category") (val "")))))

(chain
 ($ "body")
 (on
  "click"
  ".close-tag"
  (lambda (e)
    (chain ($ this) (parent) (remove)))))
