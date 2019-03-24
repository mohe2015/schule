(var __-p-s_-m-v_-r-e-g)

(import "./wiki.lisp" "handleWikiName")
(import "./search.lisp" "handleSearchQuery" "handleSearch")
(import "./quiz.lisp" "handleQuizIdResults" "handleQuizIdPlayIndex" "handleQuizIdPlay" "handleQuizIdEdit" "handleQuizCreate")
(import "./logout.lisp" "handleLogout")
(import "./login.lisp" "handleLogin")

;;(setf (chain window onerror) (lambda (message source lineno colno error)
;;			   (alert (concatenate 'string "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! " message " source: " source " lineno: " lineno " colno: " colno " error: " error))))

(chain
 ($ "body")
 (on "click" ".history-pushState"
     (lambda (e)
       (chain e (prevent-default))
       (push-state (chain ($ this) (attr "href")))
       F)))

(chain
 ($ "#refresh")
 (click (lambda (e)
	  (chain e (prevent-default))
	  (update-state)
	  F)))



(defun read-cookie (name)
  (let ((name-eq (concatenate 'string name "="))
	(ca (chain document cookie (split ";"))))
    (loop for c in ca do
	 (if (chain c (trim) (starts-with name-eq))
	     (return (chain c (trim) (substring (chain name-eq length))))))))

(defun get-url-parameter (param)
  (let* ((page-url (chain window location search (substring 1)))
	(url-variables (chain page-url (split "&"))))
    (loop for parameter-name in url-variables do
	 (setf parameter-name (chain parameter-name (split "=")))
	 (if (= (chain parameter-name 0) param)
	     (return (chain parameter-name 1))))))

(defun replace-state (url data)
  (chain window history (replace-state data nil url))
  (update-state))


(defroute "/"
  (chain ($ ".edit-button") (remove-class "disabled"))
  (replace-state "/wiki/Hauptseite"))

(setf
 (chain window onpopstate)
 (lambda (event)
   (if (chain window last-url)
       (let ((pathname (chain window last-url (split "/"))))
	 (if (and (= (chain pathname length) 4) (= (chain pathname 1) "wiki") (or (= (chain pathname 3) "create") (= (chain pathname 3) "edit")))
	     (progn
	       (if (confirm "Möchtest du die Änderung wirklich verwerfen?")
		   (update-state))
	       (return)))))
   (update-state)))

(setf
 (chain window onbeforeunload)
 (lambda ()
   (let ((pathname (chain window location pathname (split "/"))))
     (if (and (= (chain pathname length) 4) (= (chain pathname 1) "wiki") (or (= (chain pathname 3) "create") (= (chain pathname 3) "edit")))
	 T)))) ;; TODO this method is not allowed to return anything if not canceling

(lisp *UPDATE-STATE*)

(setf
  (chain window onload)
  (lambda ()
    (update-state)))
