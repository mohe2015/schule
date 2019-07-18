(defpackage spickipedia.pdf
  (:use :cl :pdf :deflate :flexi-streams :queues)
  (:export :parse :read-line-part :read-newline :line-length :current-line :extractor-lines))

(in-package :spickipedia.pdf)

(defclass pdf-text-extractor ()
  ((lines
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
    :accessor current-part))
  (:documentation "Stores extracted text to read and process it."))

(defun queue-to-string (queue)
  "Convert a character queue to a string."
  (let ((string (make-array 0 :element-type 'character :fill-pointer 0 :adjustable t)))
    (queues:map-queue (lambda (test) (vector-push-extend test string)) queue)
    string))

(defmethod write-line-part-char ((extractor pdf-text-extractor) char)
  "Add character to part of line."
  (qpush (current-part extractor) char))

(defmethod new-part ((extractor pdf-text-extractor))
  "New part of line in extracted text."
  (qpush (current-line extractor) (queue-to-string (current-part extractor)))
  (setf (current-part extractor) (make-queue :simple-queue)))

(defmethod new-line ((extractor pdf-text-extractor))
  "New line in extracted text."
  (new-part extractor)
  (qpush (extractor-lines extractor) (current-line extractor))
  (setf (current-line extractor) (make-queue :simple-queue)))

(defmethod read-line-part ((extractor pdf-text-extractor))
  "Get part of line from extracted text."
  (qpop (current-line extractor)))

(defmethod line-length ((extractor pdf-text-extractor))
  (qsize (current-line extractor)))

(defmethod read-newline ((extractor pdf-text-extractor))
  "Expect a newline in extracted text."
  (unless (= 0 (qsize (current-line extractor)))
    (error "The current line still contains parts."))
  (setf (current-line extractor) (qpop (extractor-lines extractor))))

(defun decompress-string (string)
  "Decompress a zlib string."
  (octets-to-string
   (let ((in (make-in-memory-input-stream (string-to-octets string))))
     (with-output-to-sequence (out)
       (inflate-zlib-stream in out)))))

(defun get-decompressed (file)
  "Get decompressed part of pdf file (pdf spec)."
  (let* ((pdf (read-pdf-file file))
	 (contents (map 'list 'content (objects pdf)))
	 (streams (remove-if-not (lambda (x) (typep x 'pdf-stream)) contents))
	 (jo (remove-if-not (lambda (x) (equal "/FlateDecode" (cdr (assoc "/Filter" (dict-values x) :test #'equal)))) streams))
	 (strings (mapcar 'content jo))
	 (strings2 (mapcar 'car strings))
	 (decompressed (mapcar 'decompress-string strings2)))
    (car decompressed)))

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

(defmethod draw-text-object ((extractor pdf-text-extractor) text)
  "Writes the text from the text object (pdf spec) into the text extractor."
  (loop for x across text do
       (if (typep x 'string)
	   (write-line-part-char extractor (escaped-to-char (subseq x 1 (- (length x) 1))))
	   (if (< x -280)
	       (new-part extractor)))))

(defun parse (file)
  "Parse a pdf file into a text extractor object. This can be used to read the text of an existing pdf file."
  (with-input-from-string (in (get-decompressed file))
    (let ((stack '())
	  (extractor (make-instance 'pdf-text-extractor)))
      (loop
	 (if (eq (peek-char nil in nil nil) #\[)
	     (let ((*pdf-input-stream* in))
	       (push (read-object in) stack))
	     (let ((e (read-until 'boundary-char-p in)))
	       (cond ((equal e "q"))                   ; push graphics
		     ((equal e "Q"))                   ; pop graphics
		     ((equal e "BT"))                  ; begin text
		     ((equal e "ET") (new-line extractor))
		     ((equal e "Tf") (setf stack '())) ; font and size
		     ((equal e "Tm") (setf stack '())) ; text matrix
		     ((equal e "cm") (setf stack '())) ; CTM
		     ((equal e "RG") (setf stack '())) ; stroking color
		     ((equal e "rg") (setf stack '())) ; non stroking color
		     ((equal e "TJ") (draw-text-object extractor (car stack)) (setf stack '()))
		     ((equal e "TL") (setf stack '())) ; set text leading
		     ((equal e "T*") (new-line extractor))
		     ((equal e "Td") (unless (equal "0" (car stack)) (new-line extractor)) (setf stack '()))
		     ((equal e "w")  (setf stack '())) ; line width
		     ((equal e "J")  (setf stack '())) ; line cap style
		     ((equal e "j")  (setf stack '())) ; line join style
		     ((equal e "m")  (setf stack '())) ; move to
		     ((equal e "l")  (setf stack '())) ; straight line
		     ((equal e "re") (setf stack '())) ; rectangle
		     ((equal e "gs"))                  ; graphics state operator
		     ((equal e "S"))                   ; stroke path
		     ((eq e nil) (return-from parse extractor))
		     ((eq (elt e 0) #\/))              ; literal name
		     (t (push e stack)))
	       (when (whitespace-char-p (peek-char nil in nil nil))
		 (unless (read-char in nil)
		   (return-from parse extractor)))))))))
