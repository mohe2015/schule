(defmacro defroute (route &body body)
  `(defun ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/:?" route "-") 1))) (path)
       (if (not (null (setf results (chain (new (-Reg-Exp ,(concatenate 'string "^" (regex-replace-all ":[^/]*" route "([^/]*)") "$"))) (exec path)))))
	   (progn
	     ,@(loop
		  for variable in (all-matches-as-strings ":[^/]*" route)
		  for i from 1
		  collect
		    `(defparameter ,(make-symbol (string-upcase (subseq variable 1))) (chain results ,i)))
	     ,@body))))

(setf (chain window onerror) (lambda (message source lineno colno error)
			   (alert (concatenate 'string "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! " message " source: " source " lineno: " lineno " colno: " colno " error: " error))))

(chain
 ($ "body")
 (on "click" ".history-pushState"
     (lambda (e)
       (chain e (prevent-default))
       (push-state (chain ($ this) (data "href")))
       F)))

(chain
 ($ "#refresh")
 (click (lambda (e)
	  (chain e (prevent-default))
	  (update-state)
	  F)))

(defun handle-error (thrown-error show-error-page)
  (if (= thrown-error "Authorization Required")
      (let ((name (chain ($ "#inputName") (val (chain window local-storage name)))))
	(chain window local-storage (remove-item "name"))
	((push-state "/login" (create last-url (chain window location href) last-state (chain window history state)))))
      (if (= thrown-error "Forbidden")
	  (let ((error-message "Du hast nicht die benötigten Berechtigungen, um diese Aktion durchzuführen. Sag mir Bescheid, wenn du glaubst, dass dies ein Fehler ist."))
	    (chain ($ "#errorMessage") (text error-message))
	    (if show-error-page
		(progn
		  (chain ($ "#errorMessage") (text error-message))
		  (show-tab "#error"))
		(alert error-message)))
	  (let ((error-message (concatenate 'string "Unbekannter Fehler: " thrown-error)))
	    (if show-error-page
		(progn
		  (chain ($ "#errorMessage") (text error-message))
		  (show-tab "#error"))
		(alert error-message))))))

(defun set-fullscreen (value)
  (if (and value (= (chain ($ ".fullscreen") length) 0))
      (chain ($ "article") (summernote "fullscreen.toggle"))
      (if (and (not value) (= (chain ($ ".fullscreen") length) 1))
	  (chain ($ "article") (summernote "fullscreen.toggle")))))

(defparameter finished-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "<i class=\"fa fa-check\"/>"
	tooltip "Fertig"
	click
	(lambda ()
	  (chain
	   ($ "#publish-changes-modal")
	   (on "shown.bs.modal"
	       (lambda ()
		 (chain ($ "#change-summary") (trigger "focus")))))
	  (chain ($ "#publish-changes-modal") (modal "show"))))))
     (render))))

(defparameter cancel-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "<i class=\"fa fa-times\"/>"
	tooltip "Abbrechen"
	click
	(lambda ()
	  (if (confirm "Möchtest du die Änderung wirklich verwerfen?")
	      (chain window history (back)))))))
     (render))))

(defparameter wiki-link-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "S"
	tooltip "Spickipedia-Link einfügen"
	click
	(lambda ()
	  (chain
	   ($ "#spickiLinkModal")
	   (on "shown.bs.modal"
	       (lambda ()
		 (chain ($ "#article-link-title") (trigger "focus")))))
	  (chain ($ "#spickiLinkModal") (modal "show"))))))
     (render))))

(defun read-cookie (name)
  (let ((name-eq (concatenate 'string name "="))
	(ca (chain document cookie (split ";"))))
    (loop for c in ca do
	 (if (chain c (trim) (starts-with name-eq))
	     (return (chain c (substring (chain name-eq length))))))))


(chain
 ($ "#publish-changes")
 (click
  (lambda ()
    (chain ($ "#publish-changes") (hide))
    (chain ($ "#publishing-changes") (show))

    (let ((change-summary (chain ($ "#change-summary") (val)))
	  (temp-dom (chain ($ "<output>") (append (chain $ (parse-h-t-m-l (chain ($ "article") (summernote "code")))))))
	  (article-path (chain window location pathname (substr 0 (chain window location pathname (last-index-of "/"))))))
      (chain
       temp-dom
       (find ".formula")
       (each
	(lambda ()
	  (setf (@ this inner-h-t-m-l) (concatenate 'string "\\( " (chain -math-live (get-original-content this)) " \\)")))))
      (chain $ (post (concatenate 'string "/api" article-path) (create summary change-summary html (chain temp-dom (html)) csrf_token (read-cookie "CSRF_TOKEN"))
		     (lambda (data)
		      (push-state article-path)))
	     (fail (lambda (jq-xhr text-status error-thrown)
		     (chain ($ "#publish-changes") (show))
		     (chain ($ "#publishing-changes") (hide))
		     (handle-error error-thrown F))))
      ))))

(defun send-file (file editor wel-editable)
  (chain ($ "#uploadProgressModal") (modal "show"))
  (let ((data (new (-form-data))))
    (chain data (append "file" file))
    (chain data (append "csrf_token" (read-cookie "CSRF_TOKEN")))
    (setf (@ window file-upload-finished) F)
    (setf
     (@ window file-upload-xhr)
     (chain
      $
      (ajax
       (create
	data data
	type "POST"
	xhr (lambda ()
	      (let ((my-xhr (chain $ ajax-settings (xhr))))
		(if (chain my-xhr upload)
		    (chain my-xhr upload (add-event-listener "progress" progress-handling-function F)))
		my-xhr))
	url "/api/upload"
	cache F
	content-type F
	process-data F
	success (lambda (url)
		  (setf (@ window file-upload-finished) T)
		  (chain ($ "#uploadProgressModal") (modal "hide"))
		  (chain ($ "article") (summernote "insertImage" (concatenate 'string "/api/file/" url))))
	error (lambda ()
		(if (not (@ window file-upload-finished))
		    (progn
		      (setf (@ window file-upload-finished) T)
		      (chain ($ "#uploadProgressModal") (modal "hide"))
		      (alert "Fehler beim Upload!"))))))))))

(defun progress-handling-function (e)
  (if (@ e length-computable)
      (chain ($ "#uploadProgress") (css "width" (concatenate 'string (* 100 (/ (@ e loaded) (@ e total))) "%")))))

(chain
 ($ "#uploadProgressModal")
 (on "shown.bs.modal"
     (lambda (e)
       (if (@ window file-upload-finished)
	   (chain ($ "#uploadProgressModal") (modal "hide"))))))

(chain
 ($ "#uploadProgressModal")
 (on "hide.bs.modal"
     (lambda (e)
       (if (not (@ window file-upload-finished))
	   (progn
	     (setf (@ window file-upload-finished) T)
	     (chain window file-upload-xhr (abort)))))))

(chain
 ($ "#uploadProgressModal")
 (on "hidden.bs.modal"
     (lambda (e)
       (chain ($ "#uploadProgress") (attr "width" "0%")))))

(defun show-editor ()
  (var can-call T)
  (chain
   ($ "article")
   (summernote
    (create
     lang "de-DE"
     callbacks
     (create
      on-image-upload (lambda (files)
			(send-file (chain files 0)))
      on-change (lambda (contents $editable)
		  (if (not can-call)
		      return)
		  (setf can-call F)
		  (chain window history (replace-state (create content contents) nil nil))
		  (set-timeout (lambda ()
				 (setf can-call T))
			       1000)))
     dialogs-fade T
     focus T
     buttons (create
	      finished finished-button
	      cancel cancel-button
	      wiki-link wiki-link-button)
     toolbar ([]
	      ("style" ("style.p" "style.h2" "style.h3" "superscript" "subscript"))
	      ("para" ("ul" "ol" "indent" "outdent"))
	      ("insert" ("link" "picture" "table" "math"))
	      ("management" ("undo" "redo" "finished")))
     cleaner
     (create
      action "both"
      newline "<p><br></p>"
      not-style "position:absolute;top:0;left:0;right:0"
      icon "<i class=\"note-icon\">[Your Button]</i>"
      keep-html T
      keep-only-tabs ([] "<h1>" "<h2>" "<h3>" "<h4>" "<h5>" "<h6>" "<p>" "<br>" "<ol>" "<ul>" "<li>" "<b>" "<strong>" "<i>" "<a>" "<sup>" "<sub>" "<img>")
      keep-classes F
      bad-tags ([] "style" "script" "applet" "embed" "noframes" "noscript")
      bad-attributes ([] "style" "start")
      limit-chars F
      limit-display "both"
      limit-stop F)
     popover
     (create
      math ([] "math" ("edit-math" "delete-math"))
      table ([] "add" ("addRowDown" "addRowUp" "addColLeft" "addColRight")
		"delete" ("deleteRow" "deleteCol" "deleteTable")
		"custom" ("tableHeaders"))
      image ([] "resize" ("resizeFull" "resizeHalf" "resizeQuarter" "resizeNone")
		"float" ("floatLeft" "floatRight" "floatNone")
		"remove" ("removeMedia")))
     image-attributes
     (create
      icon "<i class="note-icon-pencil"/>"
      remove-empty F
      disable-upload F))))
  (set-fullscreen T))

(defun hide-editor ()
  (set-fullscreen F)
  (chain ($ "article") (summernote "destroy"))
  (chain ($ ".tooltip") (hide)))

(chain
 ($ ".edit-button")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/edit") (chain window history state))
      F))))

(chain
 ($ "#create-article")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/create") (chain window history state))
      F))))


(chain
 ($ "#show-history")
 (click
  (lambda (e)
    (chain e (prevent-default))
    (let ((pathname (chain window location pathname (split "/"))))
      (push-state (concatenate 'string "/wiki/" (chain pathname 2) "/history") (chain window history state))
      F))))

(defun cleanup ()
  (set-fullscreen F)
  (chain ($ "article") (summernote "destroy"))
  (chain ($ "#publish-changes-modal") (modal "hide"))
  (chain ($ "#publish-changes") (show))
  (chain ($ "#publishing-changes") (hide)))

(defun show-tab (id)
  (chain ($ ".my-tab") (not id) (fade-out))
  (chain ($ id) (fade-in)))

(defun get-url-parameter (param)
  (let ((page-url (chain window location search (substring 1)))
	(url-variables (chain page-url (split "&"))))
    (loop for parameter-name in url-variables do
	 (setf parameter-name (chain parameter-name (split "=")))
	 (if (= (chain parameter-name 0) param)
	     (return (chain parameter-name 1))))))

(defun update-state ()
  (setf (chain window last-url) (chain window location pathname))
  (if (undefined (chain window local-storage name))
      (chain ($ "#logout") (text (concatenate 'string (chain window local-storage name) " abmelden")))
      (chain ($ "#logout") (text "Abmelden")))
  (if (undefined (chain window local-storage name))
      (push-state "/login" (create last-url (chain window location href)
				   last-state (chain window history state)))
      (return-from update-state)))


(defun replace-state (url data)
  (chain window history (replace-state data nil url))
  (update-state))

(defun push-state (url data)
  (chain window history (push-state data nil url))
  (update-state))

(defroute "/"
  (chain ($ ".edit-button") (remove-class "disabled"))
  (replace-state "/wiki/Hauptseite"))

(defroute "/logout"
  (chain ($ ".edit-button") (add-class "disabled"))
  (show-tab "#loading")
  (chain $ (post "/api/logout" (create csrf_token (read-cookie "CSRF_TOEN"))
		 (lambda (data)
		   (chain window local-storage (remove-item "name"))
		   (replace-state "/login")))
	 (fail (lambda (jq-xhr text-status error-thrown)
		 (handle-error error-thrown T)))))

(defroute "/login"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#publish-changes-modal") (modal "hide"))
  (let ((url-username (get-url-parameter "username"))
	(url-password (get-url-parameter "password")))
    (if (and (not (undefined url-username)) (not (undefined url-password)))
	(progn
	  (chain ($ "#inputName") (val (decode-u-r-i-component url-username)))
	  (chain ($ "#inputPassword") (val (decode-u-r-i-component url-password))))
	(if (undefined (chain window local-storage name))
	    (progn
	      (replace-state "/wiki/Hauptseite")
	      (return))))

    (show-tab "#login")
    (chain ($ ".login-hide")
	   (fade-out
	    (lambda ()
	      (chain ($ ".login-hide") (attr "style" "display: none !important")))))
    (chain ($ ".navbar-collapse") (remove-class "show"))))

(defroute "/articles"
  (show-tab "#loading")
  (chain
   $
   (get
    "/api/articles"
    (lambda (data)
      (chain data (sort (lambda (a b)
			  (chain a (locale-compare b)))))
      (chain ($ "#articles-list") (html ""))
      (loop for page in data do
	   (let ((templ ($ (chain ($ "#articles-entry") (html)))))
	     (chain templ (find "a") (text page))
	     (chain templ (find "a") (data "href" (concatenate 'string "/wiki/" page)))
	     (chain ($ "#articles-list") (append templ))))
      (show-tab "#articles")))
   (fail (lambda (jq-xhr text-status error-thrown)
	   (hande-error error-thrown T)))))
  
;; line 722
