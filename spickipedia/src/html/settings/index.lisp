(in-package :spickipedia.web)

(defun html-settings ()
  `((:div :style "display: none;" :class "container my-tab position-absolute" :id "tab-settings"
     (:h2 :class "text-center" "Einstellungen")

     (:h3 :class "text-center" "Dein Jahrgang")
     (:form :id "settings-form-select-grade"
       (:select :class "custom-select" :id "settings-select-grade" :name "grade"))
     (:a :id "settings-add-grade" :type "button" :class "btn btn-primary norefresh" "Jahrgang hinzufügen")

     (:h3 :class "text-center" "Deine Kurse")
     (:label (:input :type "checkbox" :name "test") "Test1") (:br)
     (:label (:input :type "checkbox" :name "test2") "Test12")) (:br)

    ,(modal "settings-create-grade" "Jahrgang hinzufügen"
       `((:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
          "Abbrechen")
         (:BUTTON :TYPE "submit" :CLASS "btn btn-primary" :ID "settings-button-create-grade"
          "Hinzufügen"))
       `((:DIV :CLASS "form-group"
           (:LABEL :FOR "settings-input-grade" "Jahrgang:") " "
           (:input :type "text" :id "settings-input-grade" :name "grade"))))))
