(in-package :spickipedia.web)

(defun html-settings ()
  `((:template :id "settings-student-course-html"
     (:div :class "custom-control custom-checkbox"
      (:input :type "checkbox" :class
       "custom-control-input student-course-checkbox" :id "settings-course-n")
      (:label :class "custom-control-label" :for "settings-course-n" "")))

    ,(tab "tab-settings"
       `(:h2 :class "text-center" "Einstellungen")
       `(:h3 :class "text-center" "Dein Jahrgang")
       `(:form :id "settings-form-select-grade"
          (:select :class "custom-select" :id "settings-select-grade" :name "grade"))
       `(:a :id "settings-add-grade" :type "button" :class
          "btn btn-primary norefresh" "Jahrgang hinzufügen")
       `(:h3 :class "text-center" "Deine Kurse")
       `(:div :id "settings-list-courses"
          (:label (:input :type "checkbox" :name "test") "Test1") (:br))
       `(:a :id "settings-add-course" :type "button" :class
          "btn btn-primary norefresh" "Kurs erstellen")
       `(:a :id "settings-edit-schedule" :type "button" :class
            "btn btn-primary norefresh" "Stundenplan ändern")
       `(:a :id "settings-show-schedule" :type "button" :class "btn btn-primary norefresh" "Studenplan anzeigen"))

    ,(modal "settings-create-grade" "Jahrgang hinzufügen"
      `((:button :type "button" :class "btn btn-secondary" :data-dismiss
         "modal" "Abbrechen")
        (:button :type "submit" :class "btn btn-primary" :id
         "settings-button-create-grade" "Hinzufügen"))
      `((:div :class "form-group"
         (:label :for "settings-input-grade" "Jahrgang:") " "
         (:input :type "text" :id "settings-input-grade" :name "grade"))
        ,(license-disclaimer)))

    ,(modal "settings-create-course" "Kurs erstellen"
      `((:button :type "button" :class "btn btn-secondary" :data-dismiss
         "modal" "Abbrechen")
        (:button :type "submit" :class "btn btn-primary" "Kurs erstellen"))
      `((:div :class "form-group" (:label "Fach")
         (:input :type "text" :class "form-control" :placeholder "Fach" :name
          "subject" :id "course-subject"))
        (:div :class "form-group" (:label "Typ")
         (:select :class "custom-select" :name "type" :id "course-type"
          (:option :selected "true" "GK") (:option "LK")))
        ,(teacher-select "settings-teachers-select")
        (:button :type "button" :class "btn btn-primary" :id "button-create-teacher" "LehrerIn erstellen")
        (:div :class "custom-control custom-checkbox"
         (:input :type "checkbox" :class "custom-control-input" :name
          "is-tutorial" :id "settings-is-tutorial")
         (:label :class "custom-control-label" :for "settings-is-tutorial"
          "Tutorium?"))
        (:div :class "form-group" (:label "Thema")
         (:input :type "text" :class "form-control" :placeholder "Thema" :name
          "topic" :id "course-topic"))
        ,(license-disclaimer)))

     ,(modal "settings-create-teacher" "LehrerIn hinzufügen"
       `((:button :type "button" :class "btn btn-secondary" :data-dismiss "modal" "Abbrechen")
         (:button :type "submit" :class "btn btn-primary" "Hinzufügen"))
       `(,(text-input "Name" "teacher-name" "name")
         ,(text-input "Initialien" "teacher-initial" "initial")))))
