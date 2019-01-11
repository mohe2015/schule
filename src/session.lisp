(in-package :lisp-wiki)


(defmethod session-verify ((request request))
  (let ((session-identifier (cookie-in (session-cookie-name *acceptor*) request)))
    (if session-identifier
	(mito:find-dao 'my-session :session-cookie session-identifier)
	nil)))

(defmethod session-cookie-value ((my-session my-session))
  (and my-session (my-session-cookie my-session)))

(defun start-my-session ()
  "Returns the current SESSION object. If there is no current session,
creates one and updates the corresponding data structures. In this
case the function will also send a session cookie to the browser."
  (let ((session (session *request*)))
    (when session
      (return-from start-my-session session))
    (setf session (mito:create-dao 'my-session :session-cookie (random-base64) :csrf-token (random-base64))
	  (session *request*) session)
    (set-cookie (session-cookie-name *acceptor*)
                :value (my-session-cookie session)
                :path "/"
                :http-only t
		:max-age (* 60 60 24 365))
    (set-cookie "CSRF_TOKEN"
		:value (my-session-csrf-token session)
		:path "/"
		:max-age (* 60 60 24 365))
    (session-created *acceptor* session)
    (setq *session* session)))

(defun regenerate-session (session)
  "Regenerates the cookie value. This should be used
when a user logs in according to the application to prevent against
session fixation attacks. The cookie value being dependent on ID,
USER-AGENT, REMOTE-ADDR, START, and *SESSION-SECRET*, the only value
we can change is START to regenerate a new value. Since we're
generating a new cookie, it makes sense to have the session being
restarted, in time. That said, because of this fact, calling this
function twice in the same second will regenerate twice the same value."
  (setf (my-session-cookie *SESSION*) (random-base64))
  (setf (my-session-csrf-token *SESSION*) (random-base64))
  (mito:save-dao *SESSION*)
  (set-cookie (session-cookie-name *acceptor*)
              :value (my-session-cookie session)
              :path "/"
              :http-only t
	      :max-age (* 60 60 24 365))
  (set-cookie "CSRF_TOKEN"
	      :value (my-session-csrf-token session)
	      :path "/"
	      :max-age (* 60 60 24 365)))
