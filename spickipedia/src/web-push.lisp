(defpackage :spickipdia.web-push
  (:use :cffi)
  (:export :send-push))

(cffi:define-foreign-library libembed
  (:unix (:or "/home/moritz/Documents/wiki/rust-web-push-test/target/debug/libembed.so"))
  (:t (:default "libembed.so")))

(cffi:use-foreign-library libembed)

(cffi:defcfun "send_notification" :uint32
  (p256dh :pointer)
  (auth :pointer)
  (endpoint :pointer)
  (private_key_file :pointer)
  (content :pointer))

#|
(p256dh "BJZ7fkJY8cfxpATINvtU_eRhaFsXZd5C3Goc9vEF7eTfvhS2Cnh28ghgY41gIZEhwfe1WoTJgiNCR0Fa_b05Rig")
(auth "kzIhW4lpAgYRQiDZ5NXFZg")
(endpoint "https://fcm.googleapis.com/fcm/send/edTPjs-kL7s:APA91bFs32ka6L5-keidG_IP8UbcHA2IsDzYoqyXTrW6D_kXplha4_oygvgPOIOmOE1Su67Xyc0_p4yaE7vjLuuOfLnon9t02QMW5w5OUBwyRTSk0BZJ-tKZ9L8z2yaTMrWAHszhf6kP")
(private-key-file "/home/moritz/Documents/wiki/rust-web-push-test/private.pem")
(content "this is a test notification")
|#

(defun send-push (p256dh auth endpoint private-key-file content)
  (cffi:with-foreign-strings ((p256dh-c p256dh)
			 (auth-c auth)
			 (endpoint-c endpoint)
			 (private-key-file-c private-key-file)
			 (content-c content))
    (send-notification p256dh-c auth-c endpoint-c private-key-file-c content-c)))
