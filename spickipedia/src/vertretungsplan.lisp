(defpackage spickipedia.vertretungsplan
  (:use :cl :spickipedia.pdf :spickipedia.libc :local-time :str))
(in-package :spickipedia.vertretungsplan)

(defclass vertretungsplan ()
  ())

(defun parse-vertretungsplan (file)
  (let ((extractor (parse file)))
    (read-newline extractor)
    (format t "updated ~a~%" (strptime (read-line-part extractor) "%a, %d. %b %Y %H:%M Uhr"))
    (read-newline extractor)
    (read-line-part extractor) ; date-code and school 
    (read-newline extractor)
    (let ((element (read-line-part extractor)))
      (loop
	 (cond ((equal element "Vertretungsplan für")
		(read-newline extractor)
		(let ((date (read-line-part extractor)))
		  (format t "date ~a~%" (strptime date "%A, %d. %b %Y")))
		(read-newline extractor)
		(setf element (read-line-part extractor)))
	       ((equal element "Aufsicht: v. d. Unterricht:")
		(read-newline extractor)
		(setf element (read-line-part extractor)))
	       ((starts-with? "1. Pause:" (trim element))
		(read-newline extractor)
		(setf element (read-line-part extractor)))
	       ((starts-with? "2. Pause:" (trim element))
		(read-newline extractor)
		(setf element (read-line-part extractor)))
	       ((starts-with? "Bus:" (trim element))
		(read-newline extractor)
		(setf element (read-line-part extractor)))
	       ((starts-with? "Reinigung:" (trim element))
		(read-newline extractor)
		(setf element (read-line-part extractor)))	
	       ((starts-with? "fehlende Lehrer:" (trim element))
		;; TODO read line
		(setf element (read-line-part extractor)))
			
		
	       
	       ((not element) (error "unexpected end"))
	       (t (format t "~a~%" element)))))))

 (parse-vertretungsplan #P"/home/moritz/Downloads/vs.pdf")
