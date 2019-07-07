
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(chain (one "body")
 (on "click" "article[contenteditable=false] img"
  (lambda (event)
    (if (null (chain document fullscreen-element))
        (chain event target (request-fullscreen))
        (chain document (exit-fullscreen))))))
