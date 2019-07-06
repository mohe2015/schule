
(:div :style "display: none;" :class "container my-tab position-absolute" :id
 "edit-quiz" (:h1 :class "text-center" "Quiz ändern") (:div :id "questions")
 (:button :type "button" :class
  "btn btn-primary mb-1 create-multiple-choice-question"
  "Multiple-Choice-Frage hinzufügen")
 (:button :type "button" :class "btn btn-primary mb-1 create-text-question"
  "Frage mit Textantwort hinzufügen")
 (:button :type "button" :class "btn btn-primary mb-1 save-quiz" "Speichern")) 