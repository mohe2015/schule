(defpackage spickipedia.pdf
  (:use :cl :pdf :deflate :flexi-streams :queues :log4cl)
  (:export :parse :read-line-part :read-newline :line-length :current-line :extractor-lines :read-new-page))

(in-package :spickipedia.pdf)

(defclass pdf-text-extractor (fare-mop:SIMPLE-PRINT-OBJECT-MIXIN)
  ((pages
    :initarg :pages
    :initform (make-queue :simple-queue)
    :accessor extractor-pages)
   (lines
    :initarg :lines
    :initform (make-queue :simple-queue)
    :accessor extractor-lines)
   (current-line
    :initarg :current-line
    :initform (make-queue :simple-queue)
    :accessor current-line)
   (current-part
    :initarg :current-part
    :initform (make-queue :simple-queue)
    :accessor current-part)
   (last-number-p
    :initarg :last-number-p
    :initform nil
    :accessor extractor-last-number-p))
  (:documentation "Stores extracted text to read and process it."))

(defun queue-to-string (queue)
  "Convert a character queue to a string."
  (let ((string (make-array 0 :element-type 'character :fill-pointer 0 :adjustable t)))
    (queues:map-queue (lambda (test) (vector-push-extend test string)) queue)
    string))

(defmethod write-line-part-char ((extractor pdf-text-extractor) char)
  "Add character to part of line."
  ;;(log:trace char)
  (qpush (current-part extractor) char))

(defmethod new-part ((extractor pdf-text-extractor))
  "New part of line in extracted text."
  (log:trace "")
  (qpush (current-line extractor) (queue-to-string (current-part extractor)))
  (setf (current-part extractor) (make-queue :simple-queue)))

(defmethod new-line ((extractor pdf-text-extractor))
  "New line in extracted text."
  (log:trace "")
  (new-part extractor)
  (qpush (extractor-lines extractor) (current-line extractor))
  (setf (current-line extractor) (make-queue :simple-queue)))

(defmethod new-page ((extractor pdf-text-extractor))
  "New page in extracted text."
  (log:trace "")
  (qpush (extractor-pages extractor) (extractor-lines extractor))
  (setf (extractor-lines extractor) (make-queue :simple-queue)))

(defmethod read-line-part ((extractor pdf-text-extractor))
  "Get part of line from extracted text."
  (qpop (current-line extractor)))

(defmethod line-length ((extractor pdf-text-extractor))
  (qsize (current-line extractor)))

(defun qsize? (queue)
  (if queue
      (qsize queue)
      0))

(defmethod read-newline ((extractor pdf-text-extractor))
  "Expect a newline in extracted text."
  (unless (= 0 (qsize? (current-part extractor)))
    (error "The current part still contains characters"))
  (unless (= 0 (qsize? (current-line extractor)))
    (error "The current line still contains parts."))
  (setf (current-line extractor) (qpop (extractor-lines extractor))))

(defmethod read-new-page ((extractor pdf-text-extractor))
  "Expect a new page in extracted text."
  (unless (= 0 (qsize? (current-part extractor)))
    (error "The current part still contains characters"))
  (unless (= 0 (qsize? (current-line extractor)))
    (error "The current line still contains parts."))
  (unless (= 0 (qsize? (extractor-lines extractor)))
    (error "The current page still contains lines."))
  (setf (extractor-lines extractor) (qpop (extractor-pages extractor))))

(defun decompress-string (string)
  "Decompress a zlib string."
  (octets-to-string
   (let ((in (make-in-memory-input-stream (string-to-octets string))))
     (with-output-to-sequence (out)
       (inflate-zlib-stream in out)))))

(defun get-decompressed (data)
  "Get decompressed part of pdf file (pdf spec)."
  (let* ((pdf (read-pdf-file data))
	 (contents (map 'list 'content (objects pdf)))
	 (streams (remove-if-not (lambda (x) (typep x 'pdf-stream)) contents))
	 (jo (remove-if-not (lambda (x) (equal "/FlateDecode" (cdr (assoc "/Filter" (dict-values x) :test #'equal)))) streams))
	 (strings (mapcar 'content jo))
	 (strings2 (mapcar 'car strings))
	 (decompressed (mapcar 'decompress-string strings2))
	 (removed-fonts (remove-if-not (lambda (x) (str:starts-with? "q 0.12 0 0 0.12 0 0 cm" x)) decompressed)))
    removed-fonts))

(defun read-until (test &optional (stream *standard-input*))
  "Reads string from stream until test is true."
  (unless (peek-char nil stream nil nil)
    (return-from read-until nil))
  (with-output-to-string (out)
    (loop for c = (peek-char nil stream nil nil)
       while (and c (not (funcall test c)))
       do (write-char (read-char stream) out))))

(defun whitespace-char-p (x)
  (or (char= #\space x)
      (not (graphic-char-p x))))

(defun boundary-char-p (x)
  (or (whitespace-char-p x)
      (char= #\[ x)))

(defun escaped-to-char (string)
  "Converts escaped characters from pdf files (spec) into normal characters."
  (if (= (length string) 2)
      (char string 1)
      (char string 0)))

;; 22 continue
(defmethod draw-text-object ((extractor pdf-text-extractor) text)
  "Writes the text from the text object (pdf spec) into the text extractor."
  (log:trace text)
  (loop for x across text do
       (if (typep x 'string)
	   (progn
	     (setf (extractor-last-number-p extractor) nil)
	     (write-line-part-char extractor (escaped-to-char (subseq x 1 (- (length x) 1)))))
	   (progn
	     (setf (extractor-last-number-p extractor) t)
	     (when (< x -100)
	       (new-part extractor))))))

;; (log:config :trace)
;; (log:config :daily "file.txt")

(defmethod parse-page ((extractor pdf-text-extractor) in)
  (let ((stack '()))
    (loop
       (if (eq (peek-char nil in nil nil) #\[)
	   (let ((*pdf-input-stream* in))
	     (push (read-object in) stack))
	   (let ((e (read-until 'boundary-char-p in)))
	     (cond ((equal e "q")
		    (log:trace "q - push graphics"))
		   ((equal e "Q")
		    (log:trace "Q - pop graphics"))
		   ((equal e "BT")
		    (log:trace "BT - begin text"))
		   ((equal e "ET")
		    (log:trace "ET - end text")
		    (new-line extractor))
		   ((equal e "Tf")
		    (log:trace "Tf - font and size")
		    (setf stack '())) 
		   ((equal e "Tm")
		    (log:trace "Tm - text matrix")
		    (setf stack '()))
		   ((equal e "cm")
		    (log:trace "cm - CTM")
		    (setf stack '()))
		   ((equal e "RG")
		    (log:trace "RG - stroking color")
		    (setf stack '()))
		   ((equal e "rg")
		    (log:trace "rg - non stroking color")
		    (setf stack '()))
		   ((equal e "TJ")
		    (log:trace "TJ - draw text object")
		    (draw-text-object extractor (car stack))
		    (setf stack '()))
		   ((equal e "TL")
		    (log:trace "TL - set text leading")
		    (setf stack '()))
		   ((equal e "T*")
		    (log:trace "T* - newline")
		    (new-line extractor))
		   ((equal e "Td")
		    (log:trace "Td - newline " (car stack))
		    (if (equal "0" (car stack))
			(if (extractor-last-number-p extractor)
			    (new-part extractor))
			(new-line extractor))
		    (setf stack '()))
		   ((equal e "w")
		    (log:trace "w - line width")
		    (setf stack '()))
		   ((equal e "J")
		    (log:trace "J - line cap style")
		    (setf stack '()))
		   ((equal e "j")
		    (log:trace "j - line join style")
		    (setf stack '()))
		   ((equal e "m")
		    (log:trace "m - move to")
		    (setf stack '()))
		   ((equal e "l")
		    (log:trace "l - straight line")
		    (setf stack '()))
		   ((equal e "re")
		    (log:trace "re - rectangle")
		    (setf stack '()))
		   ((equal e "gs")
		    (log:trace "gs - graphics state operator"))
		   ((equal e "S")
		    (log:trace "S - stroke path"))
		   ((eq e nil) (return-from parse-page extractor))
		   ((eq (elt e 0) #\/))              ; literal name
		   (t (push e stack)))
	     (when (whitespace-char-p (peek-char nil in nil nil))
	       (unless (read-char in nil)
		 (return-from parse-page extractor))))))))

(defun parse (data)
  "Parse a pdf file into a text extractor object. This can be used to read the text of an existing pdf file."
  (let ((extractor (make-instance 'pdf-text-extractor)))
    (loop for page in (get-decompressed data) do
	 (with-input-from-string (in page)
	   (parse-page extractor in)
	   (new-page extractor)))
    extractor))
