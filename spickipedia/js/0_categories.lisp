(chain
 ($ "#add-tag-form")
 (submit
  (lambda (e)
    (chain e (prevent-default))
    (alert (chain ($ "#new-category") (val))))))
