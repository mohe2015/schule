
(var __-p-s_-m-v_-r-e-g)

(i "./utils.lisp" "all" "one" "clearChildren")

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=false] img")
  (if (null (chain document fullscreen-element))
      (chain event target (request-fullscreen))
      (chain document (exit-fullscreen))))
