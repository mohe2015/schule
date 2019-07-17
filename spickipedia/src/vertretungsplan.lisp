(defpackage spickipedia.vertretungsplan
  (:use :cl :spickipedia.pdf))

(in-package :spickipedia.vertretungsplan)

(defclass vertretungsplan ()
  ())

(defun parse-vertretungsplan (file)
  (let ((extractor (parse file)))
    (read-newline extractor)
    (read-line-part extractor) ; date time page header
    (read-newline extractor)
    (read-line-part extractor) ; date-code and school
    (read-newline extractor)
    (let ((for-header (read-line-part extractor)))
      (cond ((equal for-header "Vertretungsplan für")
	     (read-newline extractor)
	     (let ((date (read-line-part extractor)))
	       (format t "date ~a~%" date))) ;; "%a, %d. %b %Y %H:%M Uhr"
	    (t (print for-header))))))

 (parse-vertretungsplan #P"/home/moritz/Downloads/vs.pdf")
