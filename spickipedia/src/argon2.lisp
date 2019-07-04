(in-package :spickipedia.argon2)

(define-foreign-library libargon2
  (:unix (:or "libargon2.so.1" "libargon2.so"))
  (:t (:default "libargon2")))

(use-foreign-library libargon2)

;; https://github.com/P-H-C/phc-winner-argon2/blob/master/include/argon2.h
(defctype size :unsigned-int)

;; TODO FIXME check all response codes as this is critical code
(defcenum Argon2_ErrorCodes
    (:ARGON2_OK 0)
    (:ARGON2_OUTPUT_PTR_NULL -1)
    (:ARGON2_OUTPUT_TOO_SHORT -2)
    (:ARGON2_OUTPUT_TOO_LONG -3)
    (:ARGON2_PWD_TOO_SHORT -4)
    (:ARGON2_PWD_TOO_LONG -5)
    (:ARGON2_SALT_TOO_SHORT -6)
    (:ARGON2_SALT_TOO_LONG -7)
    (:ARGON2_AD_TOO_SHORT -8)
    (:ARGON2_AD_TOO_LONG -9)
    (:ARGON2_SECRET_TOO_SHORT -10)
    (:ARGON2_SECRET_TOO_LONG -11)
    (:ARGON2_TIME_TOO_SMALL -12)
    (:ARGON2_TIME_TOO_LARGE -13)
    (:ARGON2_MEMORY_TOO_LITTLE -14)
    (:ARGON2_MEMORY_TOO_MUCH -15)
    (:ARGON2_LANES_TOO_FEW -16)
    (:ARGON2_LANES_TOO_MANY -17)
    (:ARGON2_PWD_PTR_MISMATCH -18)     ;; NULL ptr with non-zero length
    (:ARGON2_SALT_PTR_MISMATCH -19)    ;; NULL ptr with non-zero length
    (:ARGON2_SECRET_PTR_MISMATCH -20)  ;; NULL ptr with non-zero length
    (:ARGON2_AD_PTR_MISMATCH -21)      ;; NULL ptr with non-zero length
    (:ARGON2_MEMORY_ALLOCATION_ERROR -22)
    (:ARGON2_FREE_MEMORY_CBK_NULL -23)
    (:ARGON2_ALLOCATE_MEMORY_CBK_NULL -24)
    (:ARGON2_INCORRECT_PARAMETER -25)
    (:ARGON2_INCORRECT_TYPE -26)
    (:ARGON2_OUT_PTR_MISMATCH -27)
    (:ARGON2_THREADS_TOO_FEW -28)
    (:ARGON2_THREADS_TOO_MANY -29)
    (:ARGON2_MISSING_ARGS -30)
    (:ARGON2_ENCODING_FAIL -31)
    (:ARGON2_DECODING_FAIL -32)
    (:ARGON2_THREAD_FAIL -33)
    (:ARGON2_DECODING_LENGTH_FAIL -34)
    (:ARGON2_VERIFY_MISMATCH -35))

(defcenum Argon2_type
  (:Argon2_d 0)
  (:Argon2_i 1)
  (:Argon2_id 2))

(defcfun "argon2_encodedlen" size
  (t-cost :uint32)
  (m-cost :uint32)
  (parallelism :uint32)
  (saltlen size)
  (hashlen size)
  (type Argon2_type))

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

(defcfun "argon2id_verify" :int
  (encoded :pointer)
  (pwd :pointer)
  (pwdlen size))

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
