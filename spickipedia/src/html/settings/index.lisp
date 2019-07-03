(in-package :spickipedia.web)

(defun html-settings ()
  `((:template :id "settings-student-course-html"
      (:div :class "custom-control custom-checkbox"
        (:input :type "checkbox" :class "custom-control-input" :id "settings-course-n")
        (:label :class "custom-control-label" :for "settings-course-n" "")))

    (:div :style "display: none;" :class "container my-tab position-absolute" :id "tab-settings"
     (:h2 :class "text-center" "Einstellungen")

     (:h3 :class "text-center" "Dein Jahrgang")
     (:form :id "settings-form-select-grade"
       (:select :class "custom-select" :id "settings-select-grade" :name "grade"))
     (:a :id "settings-add-grade" :type "button" :class "btn btn-primary norefresh" "Jahrgang hinzufügen")

     (:h3 :class "text-center" "Deine Kurse")
     (:div :id "settings-list-courses"
       (:label (:input :type "checkbox" :name "test") "Test1") (:br))
     (:a :id "settings-add-course" :type "button" :class "btn btn-primary norefresh" "Kurs erstellen"))

    ,(modal "settings-create-grade" "Jahrgang hinzufügen"
       `((:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
          "Abbrechen")
         (:BUTTON :TYPE "submit" :CLASS "btn btn-primary" :ID "settings-button-create-grade"
          "Hinzufügen"))
       `((:DIV :CLASS "form-group"
           (:LABEL :FOR "settings-input-grade" "Jahrgang:") " "
           (:input :type "text" :id "settings-input-grade" :name "grade"))))

    ,(modal "settings-create-course" "Kurs erstellen"
        `((:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal" "Abbrechen")
          (:BUTTON :TYPE "submit" :CLASS "btn btn-primary" "Kurs erstellen"))
        `((:DIV :CLASS "form-group"
           (:label "Fach")
           (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Fach" :name "subject" :id "course-subject"))
          (:DIV :CLASS "form-group"
            (:label "Typ")
            (:select :CLASS "custom-select" :name "type" :id "course-type"
              (:option :selected "true" "GK")
              (:option "LK")))
          (:DIV :CLASS "form-group"
            (:label "LehrerIn")
            (:select :CLASS "custom-select" :id "settings-teachers-select" :name "teacher"
              (:option "Wird geladen...")))
          (:div :class "custom-control custom-checkbox"
            (:input :type "checkbox" :class "custom-control-input" :name "is-tutorial" :id "settings-is-tutorial")
            (:label :class "custom-control-label" :for "settings-is-tutorial" "Tutorium?"))
          (:DIV :CLASS "form-group"
           (:label "Thema")
           (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Thema" :name "topic" :id "course-topic"))))))
