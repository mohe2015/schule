
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(i "./editor-lib.lisp") 
(i "./math.lisp" "revertMath") 
(i "./read-cookie.lisp" "readCookie") 
(i "./push-state.lisp" "pushState") 
(chain ($ "#publish-changes")
 (click
  (lambda ()
    (chain ($ "#publish-changes") (hide))
    (chain ($ "#publishing-changes") (show))
    (let ((change-summary (chain ($ "#change-summary") (val)))
          (temp-dom (chain ($ "article") (clone)))
          (article-path (chain window location pathname (split "/") 2)))
      (revert-math temp-dom)
      (var categories
       (chain ($ "#settings-modal") (find ".closable-badge-label")
        (map (lambda () (chain this inner-text))) (get)))
      (chain $
       (post (concatenate 'string "/api/wiki/" article-path)
        (create summary change-summary html (chain temp-dom (html)) categories
         categories _csrf_token (read-cookie "_csrf_token"))
        (lambda (data)
          (push-state (concatenate 'string "/wiki/" article-path))))
       (fail
        (lambda (jq-xhr text-status error-thrown)
          (chain ($ "#publish-changes") (show))
          (chain ($ "#publishing-changes") (hide))
          (handle-error jq-xhr f)))))))) 
(export
 (defun show-editor ()
   (chain ($ "#editor") (remove-class "d-none"))
   (chain ($ "article") (attr "contenteditable" t))
   (if (= (chain ($ "article") (html)) "")
       (chain ($ "article") (html "<p></p>")))
   (chain ($ ".article-editor") (add-class "fullscreen"))
   (chain document (exec-command "defaultParagraphSeparator" f "p")))) 