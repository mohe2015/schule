
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(on ("click" "body" event :dynamic-selector "article[contenteditable=false] img")
  (if (null (chain document fullscreen-element))
      (chain event target (request-fullscreen))
      (chain document (exit-fullscreen))))
