
(in-package :spickipedia.web)
(defun html-user-courses ()
  `((:template :id "student-courses-list-html"
     (:li
      (:a :type "button" :class "btn btn-primary button-student-course-delete"
       "-")
      (:span :class "student-courses-list-subject")))
    ,(tab "list-student-courses"
       `(:h2 :class "text-center" "Deine Kurse"
          (:a :id "add-student-course" :type "button" :class
           "btn btn-primary norefresh" "+"))
       `(:ul :id "student-courses-list"))
    ,(modal "student-courses" "Kurs hinzufügen"
      `((:button :type "button" :class "btn btn-secondary" :data-dismiss
         "modal" "Abbrechen")
        (:button :type "submit" :class "btn btn-primary" :id
         "student-courses-add" "Hinzufügen"))
      `((:div :class "form-group" (:label :for "course" "Kurs:") " "
         (:select :class "custom-select" :id "student-course" :name
          "student-course"))))))
