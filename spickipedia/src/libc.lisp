(defpackage spickipedia.libc
  (:use :cl :cffi))

(in-package :spickipedia.libc)

(define-foreign-library libc
  (:unix (:or "libc.so.6" "libc.so"))
  (:t (:default "libc")))

(use-foreign-library libc)

(defcstruct tm
  (tm-sec :int)
  (tm-min :int)
  (tm-hour :int)
  (tm-mday :int)
  (tm-mon :int)
  (tm-year :int)
  (tm-wday :int)
  (tm-yday :int)
  (tm-isdst :int))

;;; http://man7.org/linux/man-pages/man3/strptime.3.html
(defcfun "strptime" :string
  (string :string)
  (format :string)
  (time-struct (:pointer (:struct tm))))

(with-foreign-strings ((string "Freitag, 28. Jun 2019")
		       (format "%A, %d. %b %Y"))
  (with-foreign-object (time '(:pointer (:struct tm)))
    (unless (equal "" (strptime string format time))
      (error "failed to parse date"))
    (with-foreign-slots ((tm-sec tm-min tm-hour tm-mday tm-mon tm-year tm-wday tm-yday tm-isdst) time (:struct tm))
      (list tm-sec tm-min tm-hour tm-mday tm-mon tm-year tm-wday tm-yday tm-isdst))))
