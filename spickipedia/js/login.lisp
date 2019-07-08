(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./get-url-parameter.lisp" "getUrlParameter")
(i "./read-cookie.lisp" "readCookie")
(i "./replace-state.lisp" "replaceState")
(i "./show-tab.lisp" "showTab")
(i "./handle-error.lisp" "handleError")
(i "./utils.lisp" "all" "one" "clearChildren")

(defroute "/login"
 (add-class (one ".edit-button") "disabled")
 (hide-modal (one "#publish-changes-modal"))
 (let ((url-username (get-url-parameter "username"))
       (url-password (get-url-parameter "password")))
   (if (and (not (undefined url-username)) (not (undefined url-password)))
       (progn
        (setf (value (one "#inputName")) (decode-u-r-i-component url-username))
        (setf (value (one "#inputPassword")) (decode-u-r-i-component url-password)))
       (if (not (undefined (chain window local-storage name)))
           (progn (replace-state "/wiki/Hauptseite") (return))))
   (show-tab "#login")
   (setf (style (one ".login-hide") display) "none !important")
   (remove-class (one ".navbar-collapse") "show")))

(on ("submit" (one "#login-form") event)
  (chain event (prevent-default))
  (chain (one "#login-button") (prop "disabled" t)
   (html
    "<span class=\"spinner-border spinner-border-sm\" role=\"status\" aria-hidden=\"true\"></span> Anmelden..."))
  (login-post f))

(defun login-post (repeated)
  (let ((name (chain (one "#inputName") (val)))
        (password (chain (one "#inputPassword") (val))))
    (chain $
     (post "/api/login"
      (create _csrf_token (read-cookie "_csrf_token") name name password
       password)
      (lambda (data)
        (chain (one "#login-button") (prop "disabled" f) (html "Anmelden"))
        (chain (one "#inputPassword") (val ""))
        (setf (chain window local-storage name) name)
        (if (and (not (null (chain window history state)))
                 (not (undefined (chain window history state last-state)))
                 (not (undefined (chain window history state last-url))))
            (replace-state (chain window history state last-url)
             (chain window history state last-state))
            (replace-state "/wiki/Hauptseite"))))
     (fail
      (lambda (jq-xhr text-status error-thrown)
        (chain window local-storage (remove-item "name"))
        (if (= (chain jq-xhr status) 403)
            (progn
             (alert "Ungültige Zugangsdaten!")
             (chain (one "#login-button") (prop "disabled" f) (html "Anmelden")))
            (if (= (chain jq-xhr status) 400)
                (if repeated
                    (progn
                     (alert "Ungültige Zugangsdaten!")
                     (chain (one "#login-button") (prop "disabled" f)
                      (html "Anmelden")))
                    (login-post t))
                (handle-error jq-xhr t))))))))
