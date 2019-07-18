(defpackage spickipedia.vertretungsplan
  (:use :cl :spickipedia.pdf :spickipedia.libc :local-time :str))
(in-package :spickipedia.vertretungsplan)

(defclass vertretungsplan ()
  ())

(defun parse-vertretungsplan (extractor)
  (unless (read-new-page extractor)
    (return-from parse-vertretungsplan t))
  (read-newline extractor)
  (format t "updated ~a~%" (strptime (replace-all "Mrz" "Mär" (read-line-part extractor)) "%a, %d. %b %Y %H:%M Uhr"))
  (read-newline extractor)
  (read-line-part extractor) ; date-code and school 
  (read-newline extractor)
  (let ((element (read-line-part extractor))
	(last-state nil))
    (loop
       (cond
	 ((or (equal element "Vertretungsplan für") (equal element "Ersatzraumplan für"))
	  (read-newline extractor)
	  (let ((date (replace-all "Mrz" "Mär" (read-line-part extractor))))
	    (format t "date ~a~%" (strptime date "%A, %d. %b %Y")))
	  (read-newline extractor)
	  (unless (current-line extractor)
	    (return-from parse-vertretungsplan t))
	  (setf element (read-line-part extractor))
	  (setf last-state :for))
	 
	 ((equal (trim element) "Aufsicht: v. d. Unterricht:")
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state nil))
	 
	 ((starts-with? "1. Pause:" (trim element))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state nil))
	 
	 ((starts-with? "2. Pause:" (trim element))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state nil))
	 
	 ((starts-with? "Bus:" (trim element))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state nil))
	 
	 ((starts-with? "fehlende Lehrer:" (trim element))
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :missing-teachers))

	 ((starts-with? "fehlende Klassen:" (trim element))
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :classes))

	 ((starts-with? "fehlende Räume:" (trim element))
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :missing-rooms))
	 
	 ;; belongs to missing teachers
	 ((and (eq last-state :missing-teachers) (starts-with? "(-) " (trim element)))
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :missing-teachers))
	 
	 ;; belongs to missing classes
	 ((and (eq last-state :classes) (starts-with? "(-) " (trim element)))
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :classes))

	 ;; belongs to missing rooms
	 ((and (eq last-state :missing-rooms) (starts-with? "(-) " (trim element)))
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :missing-rooms))

	 ;; :schedule
	 ((and (or (eq last-state :for) (eq last-state :missing-teachers) (eq last-state :classes) (eq last-state :missing-rooms)) (= 0 (line-length extractor)))
	  ;; substituion schedule starts
	  ;; TODO
	  (format t "clazz ~a~%" element)
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :schedule))
	 
	 
	 
	 ((or (eq last-state :reinigung) (starts-with? "Reinigung:" (trim element)))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :reinigung))

	 ;; belongs to :schedule
	 ((and (eq last-state :schedule) (= 0 (line-length extractor)))
	  (format t "clazz ~a~%" element)
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :schedule))

	 ;; normal schedule part
	 ((eq last-state :schedule)
	  (loop for elem = (read-line-part extractor) while elem do
	       (format t "~a~%" elem))
	  (unless (read-newline extractor)
	    (return-from parse-vertretungsplan (parse-vertretungsplan extractor)))
	  (setf element (read-line-part extractor))
	  (setf last-state :schedule))
	 
	 ((not element) (error "unexpected end"))
	 
	 (t (format t "~a~%" element) (break))))))

(loop for file in (uiop:directory-files "/home/moritz/Documents/vs/") do
     (format t "~%~a~%" file)
     (parse-vertretungsplan (parse file)))
