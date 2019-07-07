
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./replace-state.lisp" "replaceState")
(i "./update-state.lisp" "updateState")
(i "./push-state.lisp" "pushState")
(i "./editor-lib.lisp" "isLocalUrl")
(i "./register-sw.lisp")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(setf (chain window onerror)
      (lambda (message source lineno colno error)
        (alert
         (concatenate 'string
                      "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! "
                      message " source: " source " lineno: " lineno
                      " colno: " colno " error: " error))))

(if (not (chain window caches))
    (alert
     "Kein Support für Cache API, die Seite funktioniert vermutlich nicht. Melde dies dem Entwickler!"))

(on ("click" "body" event :dynamic-selector "article[contenteditable=false] a")
  (let ((url (chain (one this) (attr "href"))))
    (if (is-local-url url)
        (progn (chain event (prevent-default)) (push-state url) f)
        t)))

(on ("click" "body" event :dynamic-selector "nav a")
  (let ((url (chain (one this) (attr "href"))))
    (if (is-local-url url)
        (progn (chain event (prevent-default)) (push-state url) f)
        t)))

(on ("click" "body" event :dynamic-selector "#search a")
  (let ((url (chain (one this) (attr "href"))))
    (if (is-local-url url)
        (progn (chain e (prevent-default)) (push-state url) f)
        t)))

(on ("click" "body" event :dynamic-selector "#articles a")
  (let ((url (chain (one this) (attr "href"))))
    (if (is-local-url url)
        (progn (chain event (prevent-default)) (push-state url) f)
        t)))

(on ("click" "body" event :dynamic-selector "#history-list a")
  (let ((url (chain (one this) (attr "href"))))
    (if (is-local-url url)
        (progn (chain event (prevent-default)) (push-state url) f)
        t)))

(on ("click" "body" event :dynamic-selector "a.norefresh")
  (let ((url (chain (one this) (attr "href"))))
    (if (is-local-url url)
        (progn (chain e (prevent-default)) (push-state url) f)
        t)))

(on ("click" "#refresh" event)
  (chain event (prevent-default))
  (update-state)
  f)

(setf (chain window onpopstate)
      (lambda (event)
        (if (chain window last-url)
            (let ((pathname (chain window last-url (split "/"))))
              (if (and (= (chain pathname length) 4)
                       (= (chain pathname 1) "wiki")
                       (or (= (chain pathname 3) "create")
                           (= (chain pathname 3) "edit")))
                  (progn
                   (if (confirm
                        "Möchtest du die Änderung wirklich verwerfen?")
                       (update-state))
                   (return)))))
        (update-state)))

(setf (chain window onbeforeunload)
      (lambda ()
        (let ((pathname (chain window location pathname (split "/"))))
          (if (and (= (chain pathname length) 4)
                   (= (chain pathname 1) "wiki")
                   (or (= (chain pathname 3) "create")
                       (= (chain pathname 3) "edit")))
              t))))

(setf (chain window onload) (lambda () (update-state)))
