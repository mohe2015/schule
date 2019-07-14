
(var __-p-s_-m-v_-r-e-g)

(i "./show-tab.lisp" "showTab")
(i "./read-cookie.lisp" "readCookie")
(i "./state-machine.lisp" "replaceState")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./fetch.lisp" "checkStatus" "json" "html" "handleFetchError")

(defroute "/logout"
 (add-class (one ".edit-button") "disabled")
 (show-tab "#loading")
 (let ((form-data (new (-form-data))))
   (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
   (chain
    (fetch "/api/logout" (create method "POST" body form-data))
    (then check-status)
    (then
     (lambda (data)
       (chain window local-storage (remove-item "name"))
       (replace-state "/login")))
    (catch handle-fetch-error))))
