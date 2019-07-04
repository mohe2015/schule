(in-package :spickipedia.web)

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

(with-foreign-pointer (string 4 size)
  (lisp-string-to-foreign "Popcorns" string size)
  (loop for i from 0 below size
    collect (code-char (mem-ref string :char i))))

(defparameter *HASHLEN* 32)
(defparameter *SALTLEN* 16)
(defparameter *ENCODEDLEN* 128)

(with-foreign-pointer (encoded *ENCODEDLEN*)
  (with-foreign-pointer (salt *SALTLEN*) ;; TODO FIXME initialize with random data
    (with-foreign-string ((pwd pwdlen) "randompassword")
      (let ((t-cost 2) ;; 1-pass computation
            (m-cost (ash 1 16)) ;; 64 mebibytes memory usage
            (parallelism 1)) ;; number of threads and lanes
        (argon2id-hash-encoded t-cost m-cost parallelism pwd pwdlen salt *SALTLEN* *HASHLEN* encoded *ENCODEDLEN*)
        (foreign-string-to-lisp encoded)))))
