(defpackage spickipedia.web-push
  (:use :cl :cffi)
  (:export send-push))
(in-package :spickipedia.web-push)

(define-foreign-library libwebpush
  (:unix (:or "libwebpush.so.1" "libwebpush.so"))
  (:t (:default "libwebpush")))

(use-foreign-library libwebpush)

(defcfun "send_notification" :uint32
  (p256dh :pointer)
  (auth :pointer)
  (endpoint :pointer)
  (private_key_file :pointer)
  (content :pointer))

(defun send-push (p256dh auth endpoint private-key-file content)
  (with-foreign-strings ((p256dh-c p256dh)
			 (auth-c auth)
			 (endpoint-c endpoint)
			 (private-key-file-c private-key-file)
			 (content-c content))
    (send-notification p256dh-c auth-c endpoint-c private-key-file-c content-c)))
