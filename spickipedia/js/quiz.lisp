
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defroute "/quiz/create" (show-tab "#loading")
 (post "/api/quiz/create" (create '_csrf_token (read-cookie "_csrf_token")) t
  (push-state (concatenate 'string "/quiz/" data "/edit"))))
(defroute "/quiz/:id/edit" (show-tab "#edit-quiz"))
(defroute "/quiz/:id/play"
 (get (concatenate 'string "/api/quiz/" id) t
      (setf (chain window correct-responses) 0)
      (setf (chain window wrong-responses) 0)
      (replace-state (concatenate 'string "/quiz/" id "/play/0")
       (create data data))))
(defroute "/quiz/:id/play/:index" (setf index (parse-int index))
 (if (= (chain window history state data questions length) index)
     (progn
      (replace-state (concatenate 'string "/quiz/" id "/results"))
      (return)))
 (setf (chain window current-question)
       (elt (chain window history state data questions) index))
 (if (= (chain window current-question type) "multiple-choice")
     (progn
      (show-tab "#multiple-choice-question-html")
      (chain (one ".question-html")
       (text (chain window current-question question)))
      (chain (one "#answers-html") (text ""))
      (dotimes (i (chain window current-question responses length))
        (let ((answer (elt (chain window current-question responses) i))
              (template (one (chain (one "#multiple-choice-answer-html") (html)))))
          (chain template (find ".custom-control-label")
           (text (chain answer text)))
          (chain template (find ".custom-control-label") (attr "for" i))
          (chain template (find ".custom-control-input") (attr "id" i))
          (chain (one "#answers-html") (append template))))))
 (if (= (chain window current-question type) "text")
     (progn
      (show-tab "#text-question-html")
      (chain (one ".question-html")
       (text (chain window current-question question))))))
(defroute "/quiz/:id/results" (show-tab "#quiz-results")
 (chain (one "#result")
  (text
   (concatenate 'string "Du hast " (chain window correct-responses)
                " Fragen richtig und " (chain window wrong-responses)
                " Fragen falsch beantwortet. Das sind "
                (chain
                 (/ (* (chain window correct-responses) 100)
                    (+ (chain window correct-responses)
                       (chain window wrong-responses)))
                 (to-fixed 1) (to-locale-string))
                " %"))))
(chain (one ".multiple-choice-submit-html")
 (click
  (lambda ()
    (let ((everything-correct t) (i 0))
      (loop for answer in (chain window current-question responses)
            do (chain (one (concatenate 'string "#" i))
                (remove-class "is-valid")) (chain
                                            (one (concatenate 'string "#" i))
                                            (remove-class "is-invalid")) (if (=
                                                                              (chain
                                                                               answer
                                                                               is-correct)
                                                                              (chain
                                                                               (one
                                                                                (concatenate
                                                                                 'string
                                                                                 "#"
                                                                                 i))
                                                                               (prop
                                                                                "checked")))
                                                                             (chain
                                                                              (one
                                                                               (concatenate
                                                                                'string
                                                                                "#"
                                                                                i))
                                                                              (add-class
                                                                               "is-valid"))
                                                                             (progn
                                                                              (chain
                                                                               (one
                                                                                (concatenate
                                                                                 'string
                                                                                 "#"
                                                                                 i))
                                                                               (add-class
                                                                                "is-invalid"))
                                                                              (setf everything-correct
                                                                                      f))) (incf
                                                                                            i))
      (if everything-correct
          (incf (chain window correct-responses))
          (incf (chain window wrong-responses)))
      (chain (one ".multiple-choice-submit-html") (hide))
      (chain (one ".next-question") (show))))))
(chain (one ".text-submit-html")
 (click
  (lambda ()
    (if (= (chain (one "#text-response") (val))
           (chain window current-question answer))
        (progn
         (incf (chain window correct-response))
         (chain (one "#text-response") (add-class "is-valid")))
        (progn
         (incf (chain window wrong-responses))
         (chain (one "#text-response") (add-class "is-invalid"))))
    (chain (one ".text-submit-html") (hide))
    (chain (one ".next-question") (show)))))
(chain (one ".next-question")
 (click
  (lambda ()
    (chain (one ".next-question") (hide))
    (chain (one ".text-submit-html") (show))
    (chain (one ".multiple-choice-submit-html") (show))
    (let ((pathname (chain window location pathname (split "/"))))
      (replace-state
       (concatenate 'string "/quiz/" (chain pathname 2) "/play/"
                    (1+ (parse-int (chain pathname 4)))))))))
(chain (one ".create-multiple-choice-question")
 (click
  (lambda ()
    (chain (one "#questions")
     (append (one (chain (one "#multiple-choice-question") (html))))))))
(chain (one ".create-text-question")
 (click
  (lambda ()
    (chain (one "#questions") (append (one (chain (one "#text-question") (html))))))))
(chain (one "body")
 (on "click" ".add-response-possibility"
  (lambda (e)
    (chain (one this) (siblings ".responses")
     (append (one (chain (one "#multiple-choice-response-possibility") (html))))))))
(chain (one ".save-quiz")
 (click
  (lambda ()
    (let ((obj (new (-object)))
          (pathname (chain window location pathname (split "/"))))
      (setf (chain obj questions) (list))
      (chain (one "#questions") (children)
       (each
        (lambda ()
          (if (= (chain (one this) (attr "class")) "multiple-choice-question")
              (chain obj questions (push (multiple-choice-question (one this)))))
          (if (= (chain (one this) (attr "class")) "text-question")
              (chain obj questions (push (text-question (one this))))))))
      (post (concatenate 'string "/api/quiz" (chain pathname 2))
       (create _csrf_token (read-cookie "_csrf_token") data
        (chain -j-s-o-n (stringify obj)))
       t
       (chain window history
        (replace-state nil nil
         (concatenate 'string "/quiz/" (chain pathname 2) "/play"))))))))
(defun text-question (element)
  (create type "text" question (chain element (find ".question") (val)) answer
   (chain element (find ".answer") (val))))
(defun multiple-choice-question (element)
  (let ((obj
         (create type "multiple-choice" question
          (chain element (find ".question") (val)) responses (list))))
    (chain element (find ".responses") (children)
     (each
      (lambda ()
        (let ((is-correct
               (chain (one this) (find ".multiple-choice-response-correct")
                (prop "checked")))
              (response-text
               (chain (one this) (find ".multiple-choice-response-text") (val))))
          (chain obj responses
           (push (create text response-text is-correct is-correct)))))))
    obj))
