
(var __-p-s_-m-v_-r-e-g)

(i "./utils.lisp" "all" "one" "clearChildren")

(defun urlBase64ToUint8Array (base64String)
    (let* ((padding (chain "=" (repeat (% (- 4 (% base64String.length 4)) 4))))
          (base64  (chain (+ base64String padding) (replace (regex "/\\-/g") "+") (replace (regex "/_/g") "/")))
	  (rawData (chain window (atob base64)))
	  (outputArray (new (-Uint8-Array (chain rawData length)))))
      (loop for i from 0 to (- (chain rawData length) 1) do
           (setf (getprop outputArray i) (chain rawData (char-Code-At i))))
      outputArray))

(when (and (chain navigator service-worker) (chain window -push-manager))
  (chain
   navigator
   service-worker
   (register "/sw.lisp")
   (then
    (lambda (registration)
      (chain
       registration
       push-manager
       (subscribe
	(create
	 user-visible-only t
	 application-server-key (urlBase64ToUint8Array "BJNDT9kF9YzCy_ExMEUXumYXhfigSmPruzP7ZEkZBZDTldbVrHRo99eid1M_58O-eD-Kbl6Zp0-NfFUROKhlTY8=")))
       (then
	(lambda (push-registration)
	  (chain console (log push-registration))))
       (catch
	   (lambda (error)
	     (alert error))))))
   (catch
       (lambda (error)
	 (alert error)))))
