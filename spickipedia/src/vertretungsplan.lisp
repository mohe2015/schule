(defpackage spickipedia.vertretungsplan
  (:use :cl :spickipedia.pdf :spickipedia.libc :local-time :str))
(in-package :spickipedia.vertretungsplan)

(defun get-schedule (url)
  (dex:get url
	   :headers '(("User-Agent" . "Vertretungsplan-App Moritz Hedtke <Moritz.Hedtke@t-online.de>"))
	   :basic-auth (cons (uiop:getenv "SUBSTITUTION_SCHEDULE_USERNAME") (uiop:getenv "SUBSTITUTION_SCHEDULE_PASSWORD"))))

(defclass substitution ()
  ((hour
    :initarg :hour
    :accessor substitution-hour)
   (course
    :initarg :course
    :accessor substitution-course)
   (old-teacher
    :initarg :old-teacher
    :accessor substitution-old-teacher)
   (new-teacher
    :initarg :new-teacher
    :accessor substitution-new-teacher)
   (old-room
    :initarg :old-room
    :accessor substitution-old-room)
   (new-room
    :initarg :new-room
    :accessor substitution-new-room)
   (old-subject
    :initarg :old-subject
    :accessor substitution-old-subject)
   (new-subject
    :initarg :new-subject
    :accessor substitution-new-subject)
   (notes
    :initarg :notes
    :accessor substitution-notes)))

(defun parse-substitution (substitution-list)
  (let* ((position (position "==>" substitution-list :test 'equal))
	 (left (subseq substitution-list 0 position))
	 (right (subseq substitution-list (1+ position)))
	 (s (make-instance 'substitution)))
    (setf (substitution-hour s) (parse-integer (nth 0 left)))
    (setf (substitution-old-teacher s) (nth 1 left))
    (setf (substitution-course s) (nth 2 left))
    (setf (substitution-old-subject s) (nth 3 left))

    (cond
      ((or (= 4 (length right)) (= 5 (length right)))
       (setf (substitution-new-teacher s) (nth 0 right))
       (if (= 0 (length (substitution-new-teacher s))) ;; TODO needed?
	   (setf (substitution-new-teacher s) "?"))
       (unless (equal (nth 1 right) (substitution-course s)) ;; TODO FIXME
	 (error "course not found"))
       (setf (substitution-new-subject s) (nth 2 right))
       (setf (substitution-new-room s) (nth 3 right))
       (when (= 5 (length right))
	 (setf (substitution-notes s) (nth 4 right))))
      
      ((or (= 1 (length right)) (= 2 (length right)))
       (if (equal "-----" (nth 0 right))
	   (setf (substitution-notes s) "")
	   (if (equal "?????" (nth 0 right))
	       (setf (substitution-notes s) "?????")
	       (error "wtf2")))
       (when (= 2 (length right))
	 (setf (substitution-notes s) (concatenate 'string (substitution-notes s) (nth 1 right)))))
      (t (error "fail")))
    s))

(defclass vertretungsplan ()
  ())

(defun parse-vertretungsplan (extractor)
  (unless (read-new-page extractor)
    (return-from parse-vertretungsplan t))
  (read-newline extractor)
  (format t "updated ~a~%" (strptime (replace-all "Mrz" "Mär" (read-line-part extractor)) "%a, %d. %b %Y %H:%M Uhr"))
  (unless (equal "" (read-line-part extractor))
    (error "fail"))
  (read-newline extractor)
  (read-line-part extractor) ; date-code and school 
  (read-newline extractor)
  (let ((element (read-line-part extractor))
	(last-state nil)
	(class nil))
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
	 ((and (or (eq last-state :schedule) (eq last-state :for) (eq last-state :missing-teachers) (eq last-state :classes) (eq last-state :missing-rooms)) (= 0 (line-length extractor)))
	  ;; substituion schedule starts
	  (setf class element)
	  (format t "clazz ~a~%" element)
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :schedule))
	 
	 ((or (eq last-state :reinigung) (starts-with? "Reinigung:" (trim element)))
	  (read-newline extractor)
	  (setf element (read-line-part extractor))
	  (setf last-state :reinigung))

	 ;; normal schedule part
	 ((eq last-state :schedule)
	  (let ((substitution (cons element (loop for elem = (read-line-part extractor) while elem collect elem))))
	    (print (parse-substitution substitution)))
	  
	  (unless (read-newline extractor)
	    (return-from parse-vertretungsplan (parse-vertretungsplan extractor)))
	  (setf element (read-line-part extractor))
	  (setf last-state :schedule))
	 
	 ((not element) (error "unexpected end"))
	 
	 (t (format t "~a~%" element) (break))))))

#|(loop for file in (uiop:directory-files "/home/moritz/Documents/vs/") do
(format t "~%~a~%" file)
(parse-vertretungsplan (parse file)))|#
