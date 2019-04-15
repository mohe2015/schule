;; https://developers.google.com/web/ilt/pwa/caching-files-with-service-worker
;; https://developers.google.com/web/fundamentals/primers/service-workers/lifecycle#skip_the_waiting_phase
;; TODO call upate hourly

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
  "/webfonts/fa-solid-900.woff2"
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
    (chain self (skip-waiting))
    (chain
     event
     (wait-until
      (chain
       caches
       (open cache-name)
       (then (lambda (cache)
	       (chain cache (add-all urls-to-cache))))))))))

(defun cache-then-network (event)
  (chain
   event
   (respond-with
    (chain
     caches
     (open cache-name)
     (then
      (lambda (cache)
	(chain
	 cache
	 (match (chain event request))
	 (then
	  (lambda (response)
	    (or
	     response
	     (chain
	      (fetch (chain event request))
	      (then (lambda (response)
		      (chain cache (put (chain event request) (chain response (clone))))
		      response)))))))))))))

(defun network (event)
  (chain
   event
   (respond-with
    (chain
     caches
     (open cache-name)
     (then
      (lambda (cache)
	(chain
	 (fetch (chain event request))
	 (then (lambda (response)
		 (chain cache (put (chain event request) (chain response (clone))))
		 response)))))))))

(defun cache-then-fallback (event)
  (chain
   event
   (respond-with
    (chain
     caches
     (open cache-name)
     (then
      (lambda (cache)
	(chain
	 cache
	 (match (chain event request))
	 (then
	  (lambda (response)
	    (or
	     response
	     (chain cache (match "/"))))))))))))

(chain
 self
 (add-event-listener
  "fetch"
  (lambda (event)
    (let* ((request (chain event request))
	   (method (chain request method))
	   (url (new (-u-r-l (chain request url))))
	   (pathname (chain url pathname)))
      (if (chain pathname (starts-with "/api"))
	  (if (= method "GET")
	      (network event))
	  (cache-then-fallback event))))))