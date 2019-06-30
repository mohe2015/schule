(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")

;; TODO FIXME disabled for debugging
(if (not (chain navigator service-worker))
    (chain
     window
     (add-event-listener
      "load"
      (lambda ()
       (chain
        navigator
        service-worker
        (register "/sw.lisp")
        (then
         (lambda (registration)
           nil)
         (lambda (err)
           nil)))
       nil))))
