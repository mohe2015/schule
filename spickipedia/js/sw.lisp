(var cache-name "my-site-cache-v1")
(var
 urls-to-cache
 ([]
  "/"
  "/bootstrap.css"
  "/all.css"
  "/index.css"
  "/jquery-3.3.1.js"
  "/mathlive.core.css"
  "/mathlive.css"
  "/mathlive.js"
  "/popper.js"
  "/bootstrap.js"
  "/visual-diff.js"
  "/typeahead.bundle.js"
  "/js/index.lisp"
  "/js/test.lisp"
  "/js/replace-state.lisp"
  "/js/update-state.lisp"
  "/js/push-state.lisp"
  "/js/editor-lib.lisp"
  "/js/register-sw.lisp"
  "/js/wiki.lisp"
  "/js/search.lisp"
  "/js/quiz.lisp"
  "/js/logout.lisp"
  "/js/login.lisp"
  "/js/root.lisp"
  "/js/history.lisp"
  "/js/edit.lisp"
  "/js/create.lisp"
  "/js/articles.lisp"
  "/js/show-tab.lisp"
  "/js/categories.lisp"
  "/js/file-upload.lisp"
  "/js/cleanup.lisp"
  "/js/handle-error.lisp"
  "/js/math.lisp"
  "/js/image-viewer.lisp"
  "/js/read-cookie.lisp"
  "/js/get-url-parameter.lisp"
  "/js/editor.lisp"
  "/js/hide-editor.lisp"
  "/favicon.ico"))

(chain
 self
 (add-event-listener
  "install"
  (lambda (event)
    (chain
     event
     (wait-until
      (chain
       caches
       (open cache-name)
       (then (lambda (cache)
	       (chain cache (add-all urls-to-cache))))))))))

(chain
 self
 (add-event-listener
  "fetch"
  (lambda (event)
    (chain console (log event))
    (chain
     event
     (respond-with
      (chain
       caches
       (match (chain event request))
       (then
	(lambda (response)
	  (if response
	      (return response))
	  (fetch (chain event request))))))))))
