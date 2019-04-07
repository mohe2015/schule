(var __-p-s_-m-v_-r-e-g)

(chain
 ($ "body")
 (on
  "click"
  "article[contenteditable=false] img"
  (lambda (event)
    (if (null (chain document fullscreen-element))
	(chain event target (request-fullscreen))
	(chain document (exit-fullscreen))))))
