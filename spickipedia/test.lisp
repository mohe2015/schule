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
