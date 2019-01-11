(in-package :lisp-wiki)

(defun cache-forever ()
  (setf (header-out "Cache-Control") "max-age: 31536000"))

(defun valid-csrf () ;; ;; TODO secure string compare
  (string= (my-session-csrf-token *SESSION*) (post-parameter "csrf_token")))

(defmacro with-user-perm (permission &body body)
  `(let ((user (my-session-user *session*)))
     (if user
	 (if (can user ',permission)
	     (progn ,@body)
	     (progn
	       (setf (return-code*) +http-forbidden+)
	       nil))
	 (progn
	   (setf (return-code*) +http-authorization-required+)
	   nil))))

(defmacro defget-noauth (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
       (basic-headers)
       ,@body)))

(defmacro defget-noauth-nosession (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
       (basic-headers-nosession)
       ,@body)))

(defmacro defget-noauth-cache (name &body body)
  `(defun ,name ()
     (let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
       (basic-headers-nosession)
       (cache-forever)
       (if (header-in* "If-Modified-Since")
	   (progn
	     (setf (return-code*) +http-not-modified+)
	     nil)
	   (progn ,@body)))))

(defmacro defget (name &body body) ;; TODO assert that's really a GET request
  `(defun ,name ()
     (let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
       (basic-headers)
       (with-user-perm ,name
	 ,@body))))

(defmacro defpost-noauth (name &body body)
  `(defun ,name ()
     (let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
       (basic-headers)
       (if (valid-csrf)
	   (progn ,@body)
	   (progn
	     (start-my-session)
	     (setf (return-code*) +http-forbidden+)
	     (log-message* :ERROR "POTENTIAL ONGOING CROSS SITE REQUEST FORGERY ATTACK!!!")
	     nil)))))

(defmacro defpost (name &body body) ;; TODO assert that's really a POST REQUEST
  `(defun ,name ()
     (let ((mito:*connection* (dbi:connect-cached :postgres :username "postgres" :database-name "spickipedia")))
       (basic-headers)
       (with-user-perm ,name
	 (if (valid-csrf)
	     (progn ,@body)
	     (progn
	       (start-my-session)
	       (setf (return-code*) +http-forbidden+)
	       (log-message* :ERROR (format nil "POTENTIAL ONGOING CROSS SITE REQUEST FORGERY ATTACK!!! username: ~a" (user-name user)))
	       nil))))))

(defun basic-headers-nosession ()
  (track)
  (setf (header-out "X-Frame-Options") "DENY")
  (setf (header-out "Content-Security-Policy") "default-src 'none'; script-src 'self'; img-src 'self' data: ; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com; frame-ancestors 'none';") ;; TODO the inline css from the whsiwyg editor needs to be replaced - write an own editor sometime
  (setf (header-out "X-XSS-Protection") "1; mode=block")
  (setf (header-out "X-Content-Type-Options") "nosniff")
  (setf (header-out "Referrer-Policy") "no-referrer"))

(defun basic-headers ()
  (if (not *SESSION*)
      (start-my-session))
  (basic-headers-nosession))
