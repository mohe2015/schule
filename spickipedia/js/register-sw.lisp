
(var __-p-s_-m-v_-r-e-g)

(i "./utils.lisp" "all" "one" "clearChildren")

(when (and (chain navigator service-worker) (chain window -push-manager))
  (chain
   navigator
   service-worker
   (register "/sw.lisp")
   (then
    (lambda (registration)
      (chain registration push-manager (get-subscription))))
   (catch
       (lambda (error)
	 (alert error)))))
