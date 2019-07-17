(defpackage spickipedia.pdf
  (:use :cl :pdf :deflate :flexi-streams :queues)
  (:export :parse))

(in-package :spickipedia.pdf)

(defclass pdf-text-extractor ()
  ((lines
    :initarg :lines
    :initform (make-queue :simple-queue)
    :accessor lines)
   (current-line
    :initarg :current-line
    :initform (make-queue :simple-queue)
    :accessor current-line)
   (current-part
    :initarg :current-part
    :initform (make-queue :simple-queue)
    :accessor current-part)))

(defun queue-to-string (queue)
  (let ((string (make-array 0
                            :element-type 'character
                            :fill-pointer 0
                            :adjustable t)))
    (queues:map-queue (lambda (test) (vector-push-extend test string)) queue)
    string))

(defmethod write-line-part-char ((extractor pdf-text-extractor) char)
  (qpush (current-part extractor) char))

(defmethod new-part ((extractor pdf-text-extractor))
  (qpush (current-line extractor) (queue-to-string (current-part extractor)))
  (setf (current-part extractor) (make-queue :simple-queue)))

(defmethod new-line ((extractor pdf-text-extractor))
  (new-part extractor)
  (qpush (lines extractor) (current-line extractor))
  (setf (current-line extractor) (make-queue :simple-queue)))

(defmethod read-line-part ((extractor pdf-text-extractor))
  (qpop (current-line extractor)))

(defmethod read-newline ((extractor pdf-text-extractor))
  (assert (= 0 (qsize (current-line extractor))))
  (setf (current-line extractor) (qpop (lines extractor))))



(defun decompress-string (string)
  (octets-to-string
   (let ((in (make-in-memory-input-stream (string-to-octets string))))
     (with-output-to-sequence (out)
       (inflate-zlib-stream in out)))))

(defun get-decompressed (file)
  (let* ((pdf (read-pdf-file file))
	 (contents (map 'list 'content (objects pdf)))
	 (streams (remove-if-not (lambda (x) (typep x 'pdf-stream)) contents))
	 (jo (remove-if-not (lambda (x) (equal "/FlateDecode" (cdr (assoc "/Filter" (dict-values x) :test #'equal)))) streams))
	 (strings (mapcar 'content jo))
	 (strings2 (mapcar 'car strings))
	 (decompressed (mapcar 'decompress-string strings2)))
    (car decompressed)))

(defun read-until (test &optional (stream *standard-input*))
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
  (if (= (length string) 2)
      (char string 1)
      (char string 0)))

(defmethod draw-text ((extractor pdf-text-extractor) text)
  (loop for x across text do
       (if (typep x 'string)
	   (write-line-part-char extractor (escaped-to-char (subseq x 1 (- (length x) 1))))
	   (if (< x -280)
	       (new-part extractor)))))

(defmethod parse ((extractor pdf-text-extractor) file)
  (with-input-from-string (in (get-decompressed file))
    (let ((stack '()))
      (loop
	 (if (eq (peek-char nil in nil nil) #\[)
	     (let ((*pdf-input-stream* in))
	       (push (read-object in) stack))
	     (let ((e (read-until 'boundary-char-p in)))
	       (cond ((equal e "q") (format nil "push graphics~%"))
		     ((equal e "Q") (format nil "pop graphics~%"))
		     ((equal e "BT") (format nil "begin text~%"))
		     ((equal e "ET") (format t "~%") (new-line extractor))
		     ((equal e "Tf") (format nil "font and size ~a~%" stack) (setf stack '()))
		     ((equal e "Tm") (format nil "text matrix ~a~%" stack) (setf stack '()))
		     ((equal e "cm") (format nil "CTM ~a~%" stack) (setf stack '()))
		     ((equal e "RG") (format nil "stroking color ~a~%" stack) (setf stack '()))
		     ((equal e "rg") (format nil "non-stroking color ~a~%" stack) (setf stack '()))
		     ((equal e "TJ") (format nil "print text with positioning ~a~%" stack) (draw-text extractor (car stack)) (setf stack '()))
		     ((equal e "TL") (format nil "~%--ignore set text leading ~a~%" stack) (setf stack '()))
		     ((equal e "T*") (format t "~%") (new-line extractor))
		     ((equal e "Td") (unless (equal "0" (car stack)) (format t "~%" stack) (new-line extractor)) (setf stack '()))
		     ((equal e "w") (format nil "line width ~a~%" stack) (setf stack '()))
		     ((equal e "J") (format nil "line cap style ~a~%" stack) (setf stack '()))
		     ((equal e "j") (format nil "line join style ~a~%" stack) (setf stack '()))
		     ((equal e "m") (format nil "move to ~a~%" stack) (setf stack '()))
		     ((equal e "l") (format nil "straight line ~a~%" stack) (setf stack '()))
		     ((equal e "re") (format nil "rectangle ~a~%" stack) (setf stack '()))
		     ((equal e "gs") (format nil "graphics state operator~%"))
		     ((equal e "S") (format nil "stroke the path ~%"))
		     ((eq e nil) (return))
		     ((eq (elt e 0) #\/) (format nil "literal name ~a~%" e))
		     (t (push e stack) (format nil "push-stack ~a~%" e)))
	       (when (whitespace-char-p (peek-char nil in nil nil))
		 (unless (read-char in nil)
		   (return)))))))))

(let ((extractor (make-instance 'pdf-text-extractor)))
  (parse extractor #P"/home/moritz/Downloads/vs.pdf")
  extractor)
