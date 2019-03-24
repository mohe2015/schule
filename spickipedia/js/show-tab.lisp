(var __-p-s_-m-v_-r-e-g)

(export-default (lambda (id)
  (chain ($ ".my-tab") (not id) (fade-out))
  (chain ($ id) (fade-in))))
