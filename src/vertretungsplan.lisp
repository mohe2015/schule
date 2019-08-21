(defpackage schule.vertretungsplan
  (:use :cl :schule.pdf :schule.libc :local-time :str :schule.web)
  (:export :get-schedule :parse-vertretungsplan :substitution-schedules :update))
(in-package :schule.vertretungsplan)

(defclass substitution-schedules ()
  ((schedules
    :initform (make-hash-table)
    :accessor substitution-schedules)))

(defun update-substitution (substitution date action)
  (format t "~a ~a ~a~%" action date substitution))

(defun compare-substitutions (a b)
  (when (not (equal (substitution-class a) (substitution-class b)))
    (return-from compare-substitutions nil))
  (when (not (= (substitution-hour a) (substitution-hour b)))
    (return-from compare-substitutions nil))
  (when (not (equal (substitution-course a) (substitution-course b)))
    (return-from compare-substitutions nil))
  (when (not (equal (substitution-old-teacher a) (substitution-old-teacher b)))
    (return-from compare-substitutions nil))
  (when (not (equal (substitution-old-room a) (substitution-old-room b)))
    (return-from compare-substitutions nil))
  (when (not (equal (substitution-old-subject a) (substitution-old-subject b)))
    (return-from compare-substitutions nil))
  t)

(defun substitution-equal-not-same (a b)
  (when (compare-substitutions a b)
    (when (not (equal (substitution-new-teacher a) (substitution-new-teacher b)))
      (return-from substitution-equal-not-same t))
    (when (not (equal (substitution-new-room a) (substitution-new-room b)))
      (return-from substitution-equal-not-same t))
    (when (not (equal (substitution-new-subject a) (substitution-new-subject b)))
      (return-from substitution-equal-not-same t))
    (when (not (equal (substitution-notes a) (substitution-notes b)))
      (return-from substitution-equal-not-same t)))
  nil)

;; TODO ignore ones from the past
(defmethod update (substitution-schedules vertretungsplan)
  (loop for k being each hash-key of (substitution-schedules substitution-schedules) using (hash-value v) do
       (if (timestamp< (vertretungsplan-date v) (today))
	   (remhash k (substitution-schedules substitution-schedules))))
  
  (let ((existing-schedule (gethash (timestamp-to-unix (vertretungsplan-date vertretungsplan)) (substitution-schedules substitution-schedules))))
    (if existing-schedule
	(if (timestamp< (vertretungsplan-updated existing-schedule) (vertretungsplan-updated vertretungsplan))
	    (let* ((old (vertretungsplan-substitutions existing-schedule))
		   (new (vertretungsplan-substitutions vertretungsplan))
		   (updated (intersection old new :test #'substitution-equal-not-same))
		   (removed (set-difference old new :test #'compare-substitutions))
		   (added (set-difference new old :test #'compare-substitutions)))
	      (loop for substitution in updated do
		   (update-substitution substitution (vertretungsplan-date vertretungsplan) 'UPDATED))
	      (loop for substitution in removed do
		   (update-substitution substitution (vertretungsplan-date vertretungsplan) 'REMOVED))
	      (loop for substitution in added do
		   (update-substitution substitution (vertretungsplan-date vertretungsplan) 'ADDED))
	      (setf (gethash (timestamp-to-unix (vertretungsplan-date vertretungsplan)) (substitution-schedules substitution-schedules)) vertretungsplan)
	      (log:info "updated"))
	    (log:info "old update"))
	(progn
	  (setf (gethash (timestamp-to-unix (vertretungsplan-date vertretungsplan)) (substitution-schedules substitution-schedules)) vertretungsplan)
	  (loop for substitution in (vertretungsplan-substitutions vertretungsplan) do
	       (update-substitution substitution (vertretungsplan-date vertretungsplan) 'ADDED))))))

(defun get-schedule (url)
  (uiop:with-temporary-file (:pathname temp-path :keep t)
      (serapeum:write-stream-into-file
       (dex:get
	url
	:want-stream t
	:headers '(("User-Agent" . "Vertretungsplan-App Moritz Hedtke <Moritz.Hedtke@t-online.de>"))
	:basic-auth (cons (uiop:getenv "SUBSTITUTION_SCHEDULE_USERNAME") (uiop:getenv "SUBSTITUTION_SCHEDULE_PASSWORD")))
       temp-path
       :if-does-not-exist :create
       :if-exists :supersede)))

;; TOOD FIXME class is missing

(defclass substitution ()
  ((class
    :initarg :class
    :accessor substitution-class)
   (hour
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

(defmethod print-object ((obj substitution) out)
  (format out "~a ~a ~a ~a ~a ~a ~a ~a ~a ~a"
	  (substitution-class obj)
	  (substitution-hour obj)
	  (substitution-course obj)
	  (substitution-old-teacher obj)
	  (substitution-new-teacher obj)
	  (substitution-old-room obj)
	  (substitution-new-room obj)
	  (substitution-old-subject obj)
	  (substitution-new-subject obj)
	  (substitution-notes obj)))

(defun parse-substitution (class substitution-list)
  (let* ((position (position "==>" substitution-list :test 'equal))
	 (left (subseq substitution-list 0 position))
	 (right (subseq substitution-list (1+ position)))
	 (s (make-instance 'substitution)))
    (setf (substitution-class s) class)
    (setf (substitution-hour s) (parse-integer (nth 0 left)))
    (setf (substitution-old-teacher s) (nth 1 left))
    (setf (substitution-course s) (nth 2 left))
    (setf (substitution-old-subject s) (nth 3 left))
    (setf (substitution-old-room s) (nth 4 left))
    (cond
      ((or (= 4 (length right)) (= 5 (length right)))
       (setf (substitution-new-teacher s) (nth 0 right))
       (if (= 0 (length (substitution-new-teacher s)))
	   (setf (substitution-new-teacher s) "?"))
       (unless (equal (nth 1 right) (substitution-course s))
	 (error "course not found"))
       (setf (substitution-new-subject s) (nth 2 right))
       (setf (substitution-new-room s) (nth 3 right))
       (if (= 5 (length right))
	   (setf (substitution-notes s) (nth 4 right))
	   (setf (substitution-notes s) nil)))
     
      ((or (= 1 (length right)) (= 2 (length right)))
       (setf (substitution-new-teacher s) nil)
       (setf (substitution-new-room s) nil)
       (setf (substitution-new-subject s) nil)
       (if (equal "-----" (nth 0 right))
	   (setf (substitution-notes s) "")
	   (if (equal "?????" (nth 0 right))
	       (setf (substitution-notes s) "?????")
	       (error "wtf2")))
       (when (= 2 (length right))
	 (setf (substitution-notes s) (concatenate 'string (substitution-notes s) " " (nth 1 right)))))
      (t (error "fail")))
    s))

(defclass vertretungsplan ()
  ((date
    :accessor vertretungsplan-date)
   (updated-at
    :accessor vertretungsplan-updated)
   (substitutions
    :initform '()
    :accessor vertretungsplan-substitutions)))

(defun parse-vertretungsplan (extractor &optional (vertretungsplan (make-instance 'vertretungsplan)))
    (unless (read-new-page extractor)
      (return-from parse-vertretungsplan vertretungsplan))
    (read-newline extractor)
    (setf (vertretungsplan-updated vertretungsplan) (local-time:unix-to-timestamp (strptime (replace-all "Mrz" "Mär" (read-line-part extractor)) "%a, %d. %b %Y %H:%M Uhr")))
					;(unless (equal "" (read-line-part extractor))
					;  (error "fail"))
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
	      (setf (vertretungsplan-date vertretungsplan) (local-time:unix-to-timestamp (strptime date "%A, %d. %b %Y"))))
	    (read-newline extractor)
	    (unless (current-line extractor)
	      (return-from parse-vertretungsplan vertretungsplan))
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
		 (progn)) ;; (format t "~a~%" elem))
	    (read-newline extractor)
	    (setf element (read-line-part extractor))
	    (setf last-state :missing-teachers))

	   ((starts-with? "fehlende Klassen:" (trim element))
	    (loop for elem = (read-line-part extractor) while elem do
		 (progn)) ;;(format t "~a~%" elem))
	    (read-newline extractor)
	    (setf element (read-line-part extractor))
	    (setf last-state :classes))

	   ((starts-with? "fehlende Räume:" (trim element))
	    (loop for elem = (read-line-part extractor) while elem do
		 (progn)) ;;(format t "~a~%" elem))
	    (read-newline extractor)
	    (setf element (read-line-part extractor))
	    (setf last-state :missing-rooms))
	   
	   ;; belongs to missing teachers
	   ((and (eq last-state :missing-teachers) (starts-with? "(-) " (trim element)))
	    (loop for elem = (read-line-part extractor) while elem do
		 (progn)) ;; (format t "~a~%" elem))
	    (read-newline extractor)
	    (setf element (read-line-part extractor))
	    (setf last-state :missing-teachers))
	   
	   ;; belongs to missing classes
	   ((and (eq last-state :classes) (starts-with? "(-) " (trim element)))
	    (loop for elem = (read-line-part extractor) while elem do
		 (progn)) ;; (format t "~a~%" elem))
	    (read-newline extractor)
	    (setf element (read-line-part extractor))
	    (setf last-state :classes))

	   ;; belongs to missing rooms
	   ((and (eq last-state :missing-rooms) (starts-with? "(-) " (trim element)))
	    (loop for elem = (read-line-part extractor) while elem do
	       (progn)) ;; (format t "~a~%" elem))
	    (read-newline extractor)
	    (setf element (read-line-part extractor))
	    (setf last-state :missing-rooms))

	   ;; :schedule
	   ((and (or (eq last-state :schedule) (eq last-state :for) (eq last-state :missing-teachers) (eq last-state :classes) (eq last-state :missing-rooms)) (= 0 (line-length extractor)))
	    ;; substituion schedule starts
	    (setf class element)
	    ;;(format t "clazz ~a~%" element)
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
	      (push (parse-substitution class substitution) (vertretungsplan-substitutions vertretungsplan)))
	    (unless (read-newline extractor)
	      (return-from parse-vertretungsplan (parse-vertretungsplan extractor vertretungsplan)))
	    (setf element (read-line-part extractor))
	    (setf last-state :schedule))
	   
	   ((not element) (error "unexpected end"))
	   
	   (t #|(format t "~a~%" element)|# (break)))))
    vertretungsplan)
