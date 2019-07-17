(defpackage spickipedia.vertretungsplan
  (:use :cl :spickipedia.pdf :spickipedia.libc :local-time))

(in-package :spickipedia.vertretungsplan)

(defclass vertretungsplan ()
  ())

(defun parse-vertretungsplan (file)
  (let ((extractor (parse file)))
    (read-newline extractor)
    (format t "date ~a~%" (strptime (read-line-part extractor) "%a, %d. %b %Y %H:%M Uhr"))
    (read-newline extractor)
    (read-line-part extractor) ; date-code and school 
    (read-newline extractor)
    (let ((for-header (read-line-part extractor)))
      (cond ((equal for-header "Vertretungsplan für")
	     (read-newline extractor)
	     (let ((date (read-line-part extractor)))
	       (format t "date ~a~%" (strptime date "%A, %d. %b %Y"))))
	    (t (print for-header))))))

 (parse-vertretungsplan #P"/home/moritz/Downloads/vs.pdf")
