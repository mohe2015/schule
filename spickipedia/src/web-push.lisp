(defpackage :spickipedia.web-push
  (:use :cffi)
  (:export :send-push))

(pushnew (asdf:system-relative-pathname :spickipedia #p"rust-web-push/target/release")
         cffi:*foreign-library-directories*
         :test #'equal)

(cffi:define-foreign-library libembed
  (:t (:default "libembed.so")))

(cffi:use-foreign-library libembed)

(cffi:defcfun "send_notification" :uint32
  (p256dh :pointer)
  (auth :pointer)
  (endpoint :pointer)
  (private_key_file :pointer)
  (content :pointer))

(defun send-push (p256dh auth endpoint private-key-file content)
  (cffi:with-foreign-strings ((p256dh-c p256dh)
			 (auth-c auth)
			 (endpoint-c endpoint)
			 (private-key-file-c private-key-file)
			 (content-c content))
    (send-notification p256dh-c auth-c endpoint-c private-key-file-c content-c)))
