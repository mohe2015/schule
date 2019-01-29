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
   (get "/api/articles" T
	(chain data (sort (lambda (a b)
			    (chain a (locale-compare b)))))
	(chain ($ "#articles-list") (html ""))
	(loop for page in data do
	     (let ((templ ($ (chain ($ "#articles-entry") (html)))))
	       (chain templ (find "a") (text page))
	       (chain templ (find "a") (data "href" (concatenate 'string "/wiki/" page)))
	       (chain ($ "#articles-list") (append templ))))
	(show-tab "#articles")))

(defroute "/wiki/:name"
  (var pathname (chain window location pathname (split "/")))
  (show-tab "#loading")
  (chain ($ ".edit-button") (remove-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component (chain pathname 2))))
  (cleanup)
  
  (chain
   $
   (get
    (concatenate 'string "/api/wiki/" (chain pathname 2))
    (lambda (data)
      (chain ($ "article") (html data))
      (chain
       ($ ".formula")
       (each
	(lambda ()
	  (chain -math-live (render-math-in-element this)))))
      (show-tab "#page")))
   (fail (lambda (jq-xhr text-status error-thrown)
	   (if (= error-thrown "Not Found")
	       (show-tab "#not-found")
	       (handle-error error-thrown T))))))

(defroute "/wiki/:name/create"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))

  (if (and (not (null (chain window history state))) (not (null (chain window history state content))))
      (chain ($ "article") (html (chain window history state content)))
      (chain ($ "article") (html "")))
  (show-editor)
  (show-tab "#page"))

(defroute "/wiki/:name/edit"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#is-outdated-article") (add-class "d-none"))
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component (chain pathname 2))))
  (cleanup)
  (if (and (not (null (chain window history state))) (not (null (chain window history state content))))
      (progn
	(chain ($ "article") (html (chain window history state content)))
	(chain ($ ".formula") (each (lambda ()
				      (chain -math-live (render-math-in-element this)))))
	(show-editor)
	(show-tab "#page"))
      (progn
	(show-tab "#loading")
	(chain
	 $
	 (get
	  (concatenate 'string "/api/wiki/" (chain pathname 2))
	  (lambda (data)
	    (chain ($ "article") (html data))
	    (chain
	     ($ ".formula")
	     (each (lambda ()
		     (chain -math-live (render-math-element this)))))
	    (chain window history (replace-state (create content data) nil nil))
	    (show-editor)
	    (show-tab "#page")))
	 (fail
	  (lambda (jq-xhr text-status error-thrown)
	    (if (= error-thrown "Not Found")
		(show-tab "#not-found")
		(handle-error error-thrown T))))))))

(defroute "/wiki/:name/history"
  (chain ($ ".edit-button") (remove-class "disabled"))
  (show-tab "#loading")
  (var pathname (chain window location pathname (split "/")))
  (get (concatenate 'string "/api/history/" (chain pathname 2)) T
       (chain ($ "#history-list") (html ""))
       (loop for page in data do
	    (let ((template ($ (chain ($ "#history-item-template") (html)))))
	      (chain template (find ".history-username") (text (chain page user)))
	      (chain template (find ".history-date") (text (new (-Date (chain page created)))))
	      (chain template (find ".history-summary") (text (chain page summary)))
	      (chain template (find ".history-characters") (text (chain page size)))
	      (chain template (find ".history-show") (data "href" (concatenate 'string "/wiki/" (chain pathname 2) "/history/" (chain page id))))
	      (chain template (find ".history-diff") (data "href" (concatenate 'string "/wiki/" (chain pathname 2) "/history/" (chain page id) "/changes")))
	      (chain ($ "#history-list") (append template))))
       (show-tab "#history")))

(defroute "/wiki/:page/history/:id"
  (show-tab "#loading")
  (chain ($ ".edit-button") (remove-class "disabled"))
  (cleanup)
  (chain ($ "#wiki-article-title") (text (decode-u-r-i-component (chain pathname 2))))
  (chain
   $
   (get
    (concatenate 'string "/api/revision/" id)
    (lambda (data)
      (chain ($ "#currentVersionLink") (data "href" (concatenate 'string "/wiki/" page)))
      (chain ($ "#is-outdated-article") (remove-class "d-none"))
      (chain ($ "article") (html data))
      (chain window history (replace-state (create content data) nil nil))
      (chain
       ($ ".formula")
       (each
	(lambda ()
	  (chain -math-live (render-math-in-element this)))))
      (show-tab "#page")
      ))
   (fail
    (lambda (jq-xhr text-status error-thrown)
      (if (= error-thrown "Not Found")
	  (show-tab "#not-found")
	  (handle-error error-thrown T))))))

(defroute "/wiki/:page/history/:id/changes"
  (chain ($ ".edit-button") (add-class "disabled"))
  (chain ($ "#currentVersionLink") (data "href" (concatenate 'string "/wiki/" page)))
  (chain ($ "#is-outdated-article") (remove-class "d-none"))
  (cleanup)
  (var current-revision nil)
  (var previous-revision nil)
  (chain
   $
   (get
    (concatenate 'string "/api/revision/" id)
    (lambda (data)
      (setf current-revision data)
      (chain
       $
       (get
	(concatenate 'string "/api/previous-revision/" id)
	(lambda (data)
	  (setf previous-revision data)
	  (var diff-html (htmldiff previous-revision current-revision))
	  (chain ($ "article") (html diff-html))
	  (show-tab "#page")))
       (fail
	(lambda (jq-xhr text-status error-thrown)
	  (if (= error-thrown "Not Found")
	      (show-tab "#not-found")
	      (handle-error error-thrown T)))))))
   (fail
    (lambda (jq-xhr text-status error-thrown)
      (if (= error-thrown "Not Found")
	  (show-tab "#not-found")
	  (handle-error error-thrown T))))))

(defroute "/search/:query"
  (chain ($ ".edit-button") (add-class "disabled"))
  (show-tab "#search")
  (chain ($ "#search-query") (val query)))


(defmacro get (url show-error-page &body body)
  `(chain $
	  (get ,url (lambda (data) ,@body))
	  (fail (lambda (jq-xhr text-status error-thrown)
		  (handle-error error-thrown ,show-error-page)))))

(defmacro post (url data show-error-page &body body)
  `(chain $
	  (post ,url ,data (lambda (data) ,@body))
	  (fail (lambda (jq-xhr text-status error-thrown)
		  (handle-error error-thrown ,show-error-page)))))

(defroute "/quiz/create"
  (show-tab "#loading")
  (post "/api/quiz/create" (create 'csrf_token (read-cookie "CSRF_TOKEN")) T
	(push-state (concatenate 'string "/quiz/" data "/edit"))))

(defroute "/quiz/:id/edit"
  (show-tab "#edit-quiz"))

(defroute "/quiz/:id/play"
    (get (concatenate 'string "/api/quiz/" id) T
	 (setf (chain window correct-responses) 0)
	 (setf (chain window wrong-responses) 0)
	 (replace-state (concatenate 'string "/quiz/" id "/play/0") (create data data))))

;; 681
(defroute "/quiz/:id/play/:index"
  (setf index (parse-int index))
  (if (= (chain window history state data questions length) index)
      (progn
	(replace-state (concatenate 'string "/quiz/" id "/results"))
	(return)))
  (setf (chain window current-question) (elt (chain window history state data questions) index))
  (if (= (chain window current-question type) "multiple-choice")
      (progn
	(show-tab "#multiple-choice-question")
	(chain ($ ".question-html") (text (chain window current-question question)))
	(chain ($ "#answers-html") (text))
	;; TODO this compiles to REALLY shitty code
	(loop for answer in (chain window current-question responses)
	   for i from 0 do
	     (let ((template ($ (chain ($ "#multiple-choice-answer-html") (html)))))
	       (chain template (find ".custom-control-label") (text (chain answer text)))
	       (chain template (find ".custom-control-label") (attr "for" i))
	       (chain template (find ".custom-control-input") (attr "id" i))
	       (chain ($ "#answers-html") (append template))
	       )
	)))
  )

(chain
 ($ ".multiple-choice-submit-html")
 (click
  (lambda ()
    (let ((everything-correct T) (i 0))
      (loop for answer in (chain window current-question responses) do
	   (chain ($ (concatenate 'string "#" i)) (remove-class "is-valid"))
	   (chain ($ (concatenate 'string "#" i)) (remove-class "is-invalid"))
	   (if (= (chain answer is-correct) (chain ($ (concatenate 'string "#" i)) (prop "checked")))
	       (chain ($ (concatenate 'string "#" i)) (add-class "is-valid"))
	       (progn
		 (chain ($ (concatenate 'string "#" i)) (add-class "is-invalid"))
		 (setf everything-correct F)))
	   (incf i))
      (if everything-correct
	  (incf (chain window correct-responses))
	  (incf (chain window wrong-responses)))
      (chain ($ ".multiple-choice-submit-html") (hide))
      (chain ($ ".next-question") (show))))))

(chain
 ($ ".text-submit-html")
 (click
  (lambda ()
    (if (= (chain ($ "#text-response") (val)) (chain window current-question answer))
	(progn
	  (incf (chain window correct-response))
	  (chain ($ "#text-response") (add-class "is-valid")))
	(progn
	  (incf (chain window wrong-responses))
	  (chain ($ "#text-response") (add-class "is-invalid"))))
    (chain ($ ".text-submit-html") (hide))
    (chain ($ ".next-question") (show)))))

(chain
 ($ ".next-question")
 (click
  (lambda ()
    (chain ($ ".next-question") (hide))
    (chain ($ ".text-submit-html") (show))
    (chain ($ ".multiple-choice-submit-html") (show))
    (let ((pathname (chain window location pathname (split "/"))))
      (replace-state (concatenate 'string "/quiz/" (chain pathname 2) "/play/" (1+ (parse-int (chain pathname 4)))))))))

(chain
 ($ "#button-search")
 (click
  (lambda ()
    (let ((query (chain ($ "#search-query") (val))))
      (chain ($ "#search-create-article") (data "href" (concatenate 'string "/wiki/" query "/create")))
      (chain window history (replace-state nil nil (concatenate 'string "/search/" query)))
      (chain ($ "#search-results-loading") (stop) (fade-in))
      (chain ($ "#search-results") (stop) (fade-out))
      (if (undefined (chain window search-xhr))
	  (chain window search-xhr (abort)))
      (setf
       (chain window search-xhr)
       (chain
	$
	(get
	 (concatenate 'string "/api/search" query)
	 (lambda (data)
	   (chain ($ "#search-results-content") (html ""))
	   (let ((results-contain-query F))
	     (if (not (null data))
		 (loop for page in data do
		      (if (= (chain page title) query)
			  (setf results-contain-query T))
		      (let ((template ($ (chain ($ "#search-result-template") (html)))))
			(chain template (find ".s-title") (text (chain page title)))
			(chain template (data "href" (concatenate 'string "/wiki" (chain page title))))
			(chain template (find ".search-result-summary") (html (chain page summary)))
			(chain ($ "#search-results-content") (append template)))))
	     (if results-contain-query
		 (chain ($ "#no-search-results") (hide))
		 (chain ($ "#no-search-results") (show)))
	     (chain ($ "#search-results-loading") (stop) (fade-out))
	     (chain ($ "#search-results") (stop) (fade-in)))))
	(fail (lambda (jq-xhr text-status error-thrown)
		(if (not (= text-status "abort"))
		    (handle-error error-thrown T))))))))))

(chain
 ($ "#login-form")
 (on "submit"
     (lambda (e)
     (chain e (prevent-default))
     (let ((name (chain ($ "#inputName") (val)))
	   (password (chain ($ "#inputPassword") (val))))
       (chain ($ "#login-button") (prop "disabled" T) (html "<span class=\"spinner-border spinner-border-sm\" role=\"status\" aria-hidden=\"true\"></span> Anmelden..."))

       (login-post F)))))
     
(defun login-post (repeated)
  (chain
   $
   (post
    "/api/login"
    (create
     csrf_token (read-cookie "CSRF_TOKEN")
     name name
     password password)
    (lambda (data)
      (chain ($ "#login-button") (prop "disabled" F) (html "Anmelden"))
      (chain ($ "#inputPassword") (val ""))
      (setf (chain window local-storage name) name)
      (if (and (not (null (chain window history state)))
	       (not (undefined (chain window history state last-state)))
	       (not (undefined (chain window history state last-url))))
	  (replace-state (chain window history state last-url) (chain window history state last-state))
	  (replace-state "/wiki/Hauptseite"))))
   (fail
    (lambda (jq-xhr text-status error-thrown)
      (chain window local-storage (remove-item "name"))
      (if (= error-thrown "Forbidden")
	  (if repeated
	      (progn
		(alert "Ungültige Zugansdaten!")
		(chain ($ "#login-button") (prop "disabled" F) (html "Anmelden")))
	      (login-post T))
	  (handle-error error-thrown T))))))

(chain
 ($ ".create-multiple-choice-question")
 (click
  (lambda ()
    (chain ($ "#questions") (append ($ (chain ($ "#multiple-choice-question") (html))))))))

(chain
 ($ ".create-text-question")
 (click
  (lambda ()
    (chain ($ "#questions") (append ($ (chain ($ "#text-question") (html))))))))

(chain
 ($ "body")
 (on
  "click"
  ".add-response-possibility"
  (lambda (e)
    (chain ($ this) (siblings ".responses") (append ($ (chain ($ "#multiple-choice-response-possibility") (html))))))))

(chain
 ($ ".save-quiz")
 (click
  (lambda ()
    (let ((obj (new (-object)))
	  (pathname (chain window location pathname (split "/"))))
      (setf (chain obj questions) (list))
      (chain
       ($ "#questions")
       (children)
       (each
	(lambda ()
	  (if (= (chain ($ this) (attr "class")) "multiple-choice-question")
	      (chain obj questions (push (multiple-choice-question ($ this)))))
	  (if (= (chain ($ this) (attr "class")) "text-question")
	      (chain obj questions (push (text-question ($ this))))))))
      (post (concatenate 'string "/api/quiz" (chain pathname 2))
	    (create
	     csrf_token (read-cookie "CSRF_TOKEN")
	     data (chain -J-S-O-N (stringify obj)))
	    T
	    (chain window history (replace-state nil nil (concatenate 'string "/quiz/" (chain pathname 2) "/play"))))))))

(defun text-question (element)
  (create
   type "text"
   question (chain element (find ".question") (val))
   answer (chain element (find ".answer") (val))))

(defun multiple-choice-question (element)
  (let ((obj (create
	      type "multiple-choice"
	      question (chain element (find ".question") (val))
	      responses (list))))
    (chain
     element
     (find ".responses")
     (children)
     (each
      (lambda ()
	(let ((is-correct (chain ($ this) (find ".multiple-choice-response-correct") (prop "checked")))
	      (response-text (chain ($ this) (find ".multiple-choice-response-text") (val))))

	  (chain obj responses (push (create
				      text response-text
				      is-correct is-correct)))))))
    obj))

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

(update-state)

(setf
 (chain window onbeforeunload)
 (lambda ()
   (let ((pathname (chain window location pathname (split "/"))))
     (if (and (= (chain pathname length) 4) (= (chain pathname 1) "wiki") (or (= (chain pathname 3) "create") (= (chain pathname 3) "edit")))
	 T)))) ;; TODO this method is not allowed to return anything if not canceling

(chain
 ($ document)
 (on "input" "#search-query"
     (lambda (e)
       (chain ($ "#button-search") (click)))))
