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

(defparameter settings-button
  (lambda (context)
    (chain
     (chain
      (chain $ summernote ui)
      (button
       (create
	contents "<i class=\"fa fa-cog\"/>"
	tooltip "Einstellungen"
	click
	(lambda ()
	  (chain ($ "#settings-modal") (modal "show"))))))
     (render))))
     
(chain
 ($ "#publish-changes")
 (click
  (lambda ()
    (chain ($ "#publish-changes") (hide))
    (chain ($ "#publishing-changes") (show))

    (let ((change-summary (chain ($ "#change-summary") (val)))
	  (temp-dom (chain ($ "<output>") (append (chain $ (parse-h-t-m-l (chain ($ "article") (summernote "code")))))))
	  (article-path (chain window location pathname (substr 0 (chain window location pathname (last-index-of "/"))))))
      (revert-math temp-dom)
      (setf categories (chain
       ($ "#settings-modal")
       (find ".closable-badge-label")
       (map
	(lambda ()
	  (chain this inner-text)))
       (get)))
       
      (chain $ (post (concatenate 'string "/api" article-path) (create
								summary change-summary
								html (chain temp-dom (html))
								categories categories
								csrf_token (read-cookie "CSRF_TOKEN"))
		     (lambda (data)
		      (push-state article-path)))
	     (fail (lambda (jq-xhr text-status error-thrown)
		     (chain ($ "#publish-changes") (show))
		     (chain ($ "#publishing-changes") (hide))
		     (handle-error error-thrown F))))
      ))))
 

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
	      settings settings-button)
     toolbar ([]
	      ("style" ("style.p" "style.h2" "style.h3" "superscript" "subscript"))
	      ("para" ("ul" "ol" "indent" "outdent"))
	      ("insert" ("link" "picture" "table" "math"))
	      ("management" ("undo" "redo" "settings" "finished")))
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
      icon "<i class=\"note-icon-pencil\"/>"
      remove-empty F
      disable-upload F))))
  (set-fullscreen T))

(defun hide-editor ()
  (set-fullscreen F)
  (chain ($ "article") (summernote "destroy"))
  (chain ($ ".tooltip") (hide)))
