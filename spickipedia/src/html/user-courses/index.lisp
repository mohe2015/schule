(in-package :spickipedia.web)

(defun modal (base-id title footer body)
  `(:DIV :CLASS "modal fade" :ID ,(concatenate 'string "modal-" base-id) :TABINDEX "-1" :ROLE "dialog" :ARIA-HIDDEN "true"
     (:DIV :CLASS "modal-dialog" :ROLE "document"
      (:DIV :CLASS "modal-content"
        (:form :method "POST" :id ,(concatenate 'string "form-" base-id)
          (:DIV :CLASS "modal-header"
           (:H5 :CLASS "modal-title" ,title)
           (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
            "Close" " " (:SPAN :ARIA-HIDDEN "true" "×")))
          (:DIV :CLASS "modal-body"
           ,@body)
          (:DIV :CLASS "modal-footer"
           ,@footer))))))

(defun html-user-courses ()
  `((:template :id "student-courses-list-html"
      (:li :class "student-courses-list-subject"))

    (:div :style "display: none;" :class "container my-tab position-absolute" :id "list-student-courses"
     (:h2 :class "text-center" "Deine Kurse" (:a :id "add-student-course" :type "button" :class "btn btn-primary norefresh" "+"))
     (:ul :id "student-courses-list"))

    ,(modal "student-courses" "Kurs hinzufügen"
       `((:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
          "Abbrechen")
         (:BUTTON :TYPE "submit" :CLASS "btn btn-primary" :ID "student-courses-add"
          "Hinzufügen"))
       `((:DIV :CLASS "form-group"
           (:LABEL :FOR "course" "Kurs:") " "
           (:select :class "custom-select" :id "student-course" :name "student-course"))))))
