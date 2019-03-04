 

(defroute "/quiz/create"
  (show-tab "#loading")
  (post "/api/quiz/create" (create '_csrf_token (read-cookie "_csrf_token")) T
	(push-state (concatenate 'string "/quiz/" data "/edit"))))

(defroute "/quiz/:id/edit"
  (show-tab "#edit-quiz"))

(defroute "/quiz/:id/play"
    (get (concatenate 'string "/api/quiz/" id) T
	 (setf (chain window correct-responses) 0)
	 (setf (chain window wrong-responses) 0)
	 (replace-state (concatenate 'string "/quiz/" id "/play/0") (create data data))))

;; 681
(defroute "/quiz/:id/play/:index"
  (setf index (parse-int index))
  (if (= (chain window history state data questions length) index)
      (progn
	(replace-state (concatenate 'string "/quiz/" id "/results"))
	(return)))
  (setf (chain window current-question) (elt (chain window history state data questions) index))
  (if (= (chain window current-question type) "multiple-choice")
      (progn
	(show-tab "#multiple-choice-question-html")
	(chain ($ ".question-html") (text (chain window current-question question)))
	(chain ($ "#answers-html") (text ""))
	;; TODO this compiles to REALLY shitty code
	(dotimes (i (chain window current-question responses length))
	  (let ((answer (elt (chain window current-question responses) i))
		(template ($ (chain ($ "#multiple-choice-answer-html") (html)))))
	    (chain template (find ".custom-control-label") (text (chain answer text)))
	    (chain template (find ".custom-control-label") (attr "for" i))
	    (chain template (find ".custom-control-input") (attr "id" i))
	    (chain ($ "#answers-html") (append template))))))
  (if (= (chain window current-question type) "text")
      (progn
	(show-tab "#text-question-html")
	(chain ($ ".question-html") (text (chain window current-question question))))))

(defroute "/quiz/:id/results"
  (show-tab "#quiz-results")
  (chain ($ "#result") (text (concatenate 'string "Du hast " (chain window correct-responses) " Fragen richtig und " (chain window wrong-responses) " Fragen falsch beantwortet. Das sind " (chain (/ (* (chain window correct-responses) 100) (+ (chain window correct-responses) (chain window wrong-responses))) (to-fixed 1) (to-locale-string)) " %"))))

(chain
 ($ ".multiple-choice-submit-html")
 (click
  (lambda ()
    (let ((everything-correct T) (i 0))
      (loop for answer in (chain window current-question responses) do
	   (chain ($ (concatenate 'string "#" i)) (remove-class "is-valid"))
	   (chain ($ (concatenate 'string "#" i)) (remove-class "is-invalid"))
	   (if (= (chain answer is-correct) (chain ($ (concatenate 'string "#" i)) (prop "checked")))
	       (chain ($ (concatenate 'string "#" i)) (add-class "is-valid"))
	       (progn
		 (chain ($ (concatenate 'string "#" i)) (add-class "is-invalid"))
		 (setf everything-correct F)))
	   (incf i))
      (if everything-correct
	  (incf (chain window correct-responses))
	  (incf (chain window wrong-responses)))
      (chain ($ ".multiple-choice-submit-html") (hide))
      (chain ($ ".next-question") (show))))))

(chain
 ($ ".text-submit-html")
 (click
  (lambda ()
    (if (= (chain ($ "#text-response") (val)) (chain window current-question answer))
	(progn
	  (incf (chain window correct-response))
	  (chain ($ "#text-response") (add-class "is-valid")))
	(progn
	  (incf (chain window wrong-responses))
	  (chain ($ "#text-response") (add-class "is-invalid"))))
    (chain ($ ".text-submit-html") (hide))
    (chain ($ ".next-question") (show)))))

(chain
 ($ ".next-question")
 (click
  (lambda ()
    (chain ($ ".next-question") (hide))
    (chain ($ ".text-submit-html") (show))
    (chain ($ ".multiple-choice-submit-html") (show))
    (let ((pathname (chain window location pathname (split "/"))))
      (replace-state (concatenate 'string "/quiz/" (chain pathname 2) "/play/" (1+ (parse-int (chain pathname 4)))))))))


(chain
 ($ ".create-multiple-choice-question")
 (click
  (lambda ()
    (chain ($ "#questions") (append ($ (chain ($ "#multiple-choice-question") (html))))))))

(chain
 ($ ".create-text-question")
 (click
  (lambda ()
    (chain ($ "#questions") (append ($ (chain ($ "#text-question") (html))))))))

(chain
 ($ "body")
 (on
  "click"
  ".add-response-possibility"
  (lambda (e)
    (chain ($ this) (siblings ".responses") (append ($ (chain ($ "#multiple-choice-response-possibility") (html))))))))

(chain
 ($ ".save-quiz")
 (click
  (lambda ()
    (let ((obj (new (-object)))
	  (pathname (chain window location pathname (split "/"))))
      (setf (chain obj questions) (list))
      (chain
       ($ "#questions")
       (children)
       (each
	(lambda ()
	  (if (= (chain ($ this) (attr "class")) "multiple-choice-question")
	      (chain obj questions (push (multiple-choice-question ($ this)))))
	  (if (= (chain ($ this) (attr "class")) "text-question")
	      (chain obj questions (push (text-question ($ this))))))))
      (post (concatenate 'string "/api/quiz" (chain pathname 2))
	    (create
	     _csrf_token (read-cookie "_csrf_token")
	     data (chain -J-S-O-N (stringify obj)))
	    T
	    (chain window history (replace-state nil nil (concatenate 'string "/quiz/" (chain pathname 2) "/play"))))))))

(defun text-question (element)
  (create
   type "text"
   question (chain element (find ".question") (val))
   answer (chain element (find ".answer") (val))))

(defun multiple-choice-question (element)
  (let ((obj (create
	      type "multiple-choice"
	      question (chain element (find ".question") (val))
	      responses (list))))
    (chain
     element
     (find ".responses")
     (children)
     (each
      (lambda ()
	(let ((is-correct (chain ($ this) (find ".multiple-choice-response-correct") (prop "checked")))
	      (response-text (chain ($ this) (find ".multiple-choice-response-text") (val))))

	  (chain obj responses (push (create
				      text response-text
				      is-correct is-correct)))))))
    obj))
