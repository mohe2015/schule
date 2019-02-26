(chain
 ($ "#add-tag-form")
 (submit
  (lambda (e)
    (chain e (prevent-default))
    (alert (chain ($ "#new-category") (val)))
    (alert (lisp (who-ps-html (:a :href "https://google.de" "Google"))))

    )))
