(in-package :spickipedia.argon2)

(define-foreign-library libargon2
  (:unix (:or "libargon2.so.1" "libargon2.so"))
  (:t (:default "libargon2")))

(use-foreign-library libargon2)

;; https://github.com/P-H-C/phc-winner-argon2/blob/master/include/argon2.h
(defctype size :unsigned-int)

(defcfun "argon2id_hash_encoded" :int
  (t-cost :uint32)
  (m-cost :uint32)
  (parallelism :uint32)
  (pwd :pointer)
  (pwdlen size)
  (salt :pointer)
  (saltlen size)
  (hashlen size)
  (encoded :pointer)
  (encodedlen size))

(defparameter *HASHLEN* 32)
(defparameter *SALTLEN* 16)
(defparameter *ENCODEDLEN* 128)

(defun hash (password)
  (with-foreign-pointer (encoded *ENCODEDLEN*)
    (with-foreign-array (salt (crypto:random-data *SALTLEN*) `(:array :uint8 ,*SALTLEN*))
      (with-foreign-string ((pwd pwdlen) password)
        (let ((t-cost 2) ;; 1-pass computation
              (m-cost (ash 1 16)) ;; 64 mebibytes memory usage
              (parallelism 1)) ;; number of threads and lanes
          (argon2id-hash-encoded t-cost m-cost parallelism pwd pwdlen salt *SALTLEN* *HASHLEN* encoded *ENCODEDLEN*)
          (foreign-string-to-lisp encoded))))))
