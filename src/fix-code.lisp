;; sed -r -i 's/[(]chain (.*) [(]modal "hide"[)][)]/(hide-modal \1)/g' *.lisp

(ql:quickload :trivia)
(use-package :trivia)

(match '(chain (one "#test") (modal "hide"))
  ((list 'chain a (list 'modal "hide"))
   (list 'hide-modal a)))

(defun fix-code (code)
  (let ((result (match code
		  ((list 'chain a (list 'modal "hide"))
		   (list 'hide-modal a))
		  ((cons x y)
		   (cons (fix-code x) (fix-code y))))))
    (if result result code)))

(fix-code '(if t (chain (one "#test") (modal "hide")) (progn)))

(defun fix-file (file)
  (let ((*print-case* :downcase)
	(result (with-open-file (in file)
		  (loop for sexp = (read in nil) while sexp collect (fix-code sexp)))))
    (with-open-file (out file :direction :output :if-exists :supersede)
      (loop for sexp in result do
	   (write sexp :stream out )))))

(loop for file in (directory "schule/**/*.lisp") do
     (fix-file file))
