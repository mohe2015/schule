(export-default (lambda (id)
  (chain ($ ".my-tab") (not id) (fade-out))
  (chain ($ id) (fade-in))))
