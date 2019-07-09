(var static-cache-name "static-cache-v1")

(var dynamic-cache-name "dynamic-cache-v1")

(var urls-to-cache
     ([] "/" "/bootstrap.min.css" "/all.css" "/index.css" "/jquery-3.3.1.js"
      "/mathlive.core.css" "/mathlive.css" "/mathlive.js" "/popper.js"
      "/bootstrap.min.js" "/visual-diff.js" "/webfonts/fa-solid-900.woff2"
      "/js/index.lisp" "/js/replace-state.lisp"
      "/js/update-state.lisp" "/js/push-state.lisp" "/js/editor-lib.lisp"
      "/js/register-sw.lisp" "/js/wiki.lisp" "/js/search.lisp" "/js/quiz.lisp"
      "/js/logout.lisp" "/js/login.lisp" "/js/root.lisp" "/js/history.lisp"
      "/js/edit.lisp" "/js/create.lisp" "/js/articles.lisp" "/js/show-tab.lisp"
      "/js/categories.lisp" "/js/file-upload.lisp" "/js/cleanup.lisp"
      "/js/math.lisp" "/js/image-viewer.lisp"
      "/js/read-cookie.lisp" "/js/get-url-parameter.lisp" "/js/editor.lisp"
      "/js/hide-editor.lisp" "/js/teachers.lisp" "/js/fetch.lisp"
      "/js/template.lisp" "/js/courses/new.lisp" "/js/courses/index.lisp"
      "/js/student-courses/index.lisp" "/js/schedule/id.lisp"
      "/js/schedules/new.lisp" "/js/schedules/index.lisp"
      "/js/settings/index.lisp" "/js/utils.lisp" "/favicon.ico"))

(chain self
 (add-event-listener "install"
  (lambda (event)
    (chain self (skip-waiting))
    (chain event
     (wait-until
      (chain caches (open static-cache-name)
       (then (lambda (cache) (chain cache (add-all urls-to-cache))))))))))

(defun network-and-cache (event cache-name)
  (chain event
   (respond-with
    (chain caches (open cache-name)
     (then
      (lambda (cache)
        (chain (fetch (chain event request))
         (then
          (lambda (response)
            (chain cache (put (chain event request) (chain response (clone))))
            response)))))))))

(defun cache-then-fallback (event cache-name)
  (chain event
   (respond-with
    (chain caches (open cache-name)
     (then
      (lambda (cache)
        (chain cache (match (chain event request))
         (then
          (lambda (response) (or response (chain cache (match "/"))))))))))))

(chain self
 (add-event-listener "fetch"
  (lambda (event)
    (let* ((request (chain event request))
           (method (chain request method))
           (url (new (-u-r-l (chain request url))))
           (pathname (chain url pathname)))
      (if (chain pathname (starts-with "/api"))
          (network-and-cache event dynamic-cache-name)
          (cache-then-fallback event static-cache-name))))))

(chain self
 (add-event-listener "activate"
  (lambda (event)
    (chain event
     (wait-until
      (chain caches (keys)
       (then
        (lambda (cache-names)
          (chain -promise
           (all
            (chain cache-names
             (filter
              (lambda (cache-name)
                (if (= cache-name static-cache-name)
                    (return f))
                (if (= cache-name dynamic-cache-name)
                    (return f))
                t))
             (map
              (lambda (cache-name)
                (var fun (chain caches delete))
                (chain console (log cache-name))
                (chain fun (call caches cache-name)))))))))))))))
