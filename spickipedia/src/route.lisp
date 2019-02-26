(in-package :cl-user)
(defpackage spickipedia.route
  (:use :cl))
(in-package :spickipedia.route)

(defun cache-forever ()
  (setf (header-out "Cache-Control") "max-age: 31536000"))

(defun valid-csrf () ;; TODO secure string compare
  (string= (my-session-csrf-token *SESSION*) (post-parameter "csrf_token")))

(defun basic-headers ()
  (track)
  (setf (header-out "X-Frame-Options") "DENY")
  (setf (header-out "Content-Security-Policy") "default-src 'none'; script-src 'self'; img-src 'self' data: ; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self'; frame-src www.youtube.com youtube.com; frame-ancestors 'none';") ;; TODO the inline css from the whsiwyg editor needs to be replaced - write an own editor sometime
  (setf (header-out "X-XSS-Protection") "1; mode=block")
  (setf (header-out "X-Content-Type-Options") "nosniff")
  (setf (header-out "Referrer-Policy") "no-referrer"))
