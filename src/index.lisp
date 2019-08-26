(in-package :schule.web)

(defun get-html ()
  `(:html :lang "en"
    (:head (:meta :charset "utf-8")
      (:meta :name "viewport" :content
       "width=device-width, initial-scale=1, shrink-to-fit=no")
      (:link :rel "stylesheet" :href "/bootstrap.css")
      (:link :rel "stylesheet" :href "/all.css")
      (:link :rel "stylesheet" :href "/index.css")
      (:title "Spickipedia"))
    (:body

     (:template :id "multiple-choice-answer-html"
           ,(checkbox-input "Check this custom" "customCheck1" "name"))

     (:template :id "teachers-list-html" (:li :class "teachers-list-name"))

     (:template :id "courses-list-html" (:li :class "courses-list-subject"))

     (:template :id "schedules-list-html"
           (:li (:a :class "schedules-list-grade norefresh")))

     (:template :id "multiple-choice-question"
           (:div :class "multiple-choice-question"
            (:form
                ,(text-input "Frage eingeben" "random-id-1" "question" :classes "question")
                (:div :class "responses")
                (:button :type "button" :class
                      "btn btn-primary mb-1 add-response-possibility"
                      "Antwortmöglichkeit hinzufügen"))
            (:hr)))

     (:template :id "text-question"
           (:div :class "text-question"
            (:form
                ,(text-input "Frage eingeben" "random-id-2" "question" :classes "question")
                ,(text-input "Antwort eingeben" "random-id-3" "answer" :classes "answer"))
            (:hr)))

     (:template :id "multiple-choice-response-possibility"
           (:div :class "input-group mb-3"
            (:div :class "input-group-prepend"
               (:div :class "input-group-text"
                   (:input :class "multiple-choice-response-correct" :type "checkbox"
                          :aria-label "Checkbox for following text input")))
            (:input :type "text" :class "form-control multiple-choice-response-text"
                 :aria-label "Text input with checkbox")))

     (:template :id "search-result-template"
           (:a :class "list-group-item list-group-item-action"
            (:div
                (:div (:h5 :class "mt-0 s-title" "Media heading")
                   (:div :class "search-result-summary word-wrap")))))

     (:template :id "history-item-template" " "
           (:div :class "list-group-item list-group-item-action"
            (:div :class "d-flex w-100 justify-content-between"
               (:h5 :class "mb-1 history-username" "Moritz Hedtke")
               (:small :class "history-date" "vor 3 Tagen"))
            (:p :class "mb-1 history-summary" "Ein paar wichtige Infos hinzugefügt")
            (:small (:span :class "history-characters" "50.322") " Zeichen"
                 (:span :class "text-success d-none" "+ 50 Zeichen"))
            (:div :class "btn-group w-100" :role "group" :aria-label "Basic example"
               (:a :type "button" :class "btn btn-outline-dark history-show"
                       (:i :class "fas fa-eye"))
               (:a :type "button" :class "btn btn-outline-dark history-diff"
                       (:i :class "fas fa-columns")))))

     (:template :id "articles-entry"
           (:li (:a :class "" :href "#" "Hauptseite")))

     (:template :id "template-category"
           (:span :class "closable-badge bg-secondary"
            (:span :class "closable-badge-label")
            (:button :type "button" :class "close close-tag" :aria-label "Close"
              (:span :aria-hidden "true" "&times;"))))

     (:template :id "template-readonly-category"
           (:span :class "closable-badge bg-secondary"))

     (:nav :class "navbar navbar-expand-md navbar-light bg-light"
      (:a :class "navbar-brand " :href "/wiki/Hauptseite" "Spickipedia ")
      (:div :class "login-hide"
              (:a :class "btn d-inline d-md-none edit-button"
               (:i :class "fas fa-pen"))
              #|(:a :class "btn d-inline d-md-none search-button " :href "/search")
              (:i :class "fas fa-search")|#
              (:button :class "navbar-toggler" :type "button" :data-toggle "collapse"
               :data-target "#navbarSupportedContent" :aria-controls
               "navbarSupportedContent" :aria-expanded "false" :aria-label
               "Toggle navigation" (:span :class "navbar-toggler-icon")))
      (:div :class "collapse navbar-collapse" :id "navbarSupportedContent"
              (:ul :class "navbar-nav mr-auto"
               #|(:li :class "nav-item d-none d-md-block")
               (:a :class "nav-link search-button " :href "/search" "Suchen")|#
               (:li :class "nav-item d-none d-md-block"
                 (:a :class "nav-link edit-button" :href "" "Bearbeiten"))
               (:li :class "nav-item"
                 (:a :class "nav-link" :href "/settings" "Einstellungen"))
               (:li :class "nav-item"
                 (:a :class "nav-link" :href "/contact" "Kontakt"))
               (:li :class "nav-item"
                 (:a :class "nav-link" :href "/logout" :id "logout" "Abmelden"))))))

    (:div
     ,(tab "edit-quiz"
       `(:h1 :class "text-center" "Quiz ändern")
       `(:div :id "questions")
       `(:button :type "button" :class
             "btn btn-primary mb-1 create-multiple-choice-question"
             "Multiple-Choice-Frage hinzufügen")
       `(:button :type "button" :class
             "btn btn-primary mb-1 create-text-question"
             "Frage mit Textantwort hinzufügen")
       `(:button :type "button" :class "btn btn-primary mb-1 save-quiz"
             "Speichern"))

     ,(contact-html)

     ,(tab "articles"
       `(:h1 :class "text-center" "Alle Artikel")
       `(:ul :id "articles-list"))

     ,(tab "tags"
       `(:h1 :class "text-center" "Tags")
       `(:ul :id "tags-list"))

     ,(tab "create-schedule-tab"
       `(:form :method "POST" :action "/api/schedules" :id "create-schedule-form"
           ,(text-input "Jahrgang" "schedule-grade" "grade")
           ,(submit-button "Stundenplan erstellen")))

     ,@(html-settings)
     ,@(template-substitution-schedule)

     ,(tab "multiple-choice-question-html"
       `(:h2 :class "text-center question-html" "Dies ist eine Testfrage?")
       `(:div :class "row justify-content-center"
          (:div :class "col col-sm-10 col-md-6" (:div :id "answers-html")
                   (:button :type "button" :class
                         "btn btn-primary mt-1 multiple-choice-submit-html" "Absenden")
                   (:button :type "button" :class
                         "btn btn-primary mt-1 next-question d-none" "Nächste Frage"))))

     ,(tab "quiz-results"
       `(:h1 :class "text-center" "Ergebnisse")
       `(:p :id "result"))

     ,(tab "list-teachers"
       `(:h2 :class "text-center" "Lehrer"
               (:a :href "/teachers/new" :type "button" :class
                "btn btn-primary norefresh" "+"))
       `(:ul :id "teachers-list"))

     ,@(html-user-courses)

     ,@(html-schedule)

     ,(tab "list-schedules"
       `(:h2 :class "text-center" "Stundenpläne"
               (:a :href "/schedules/new" :type "button" :class
                "btn btn-primary norefresh" "+"))
       `(:ul :id "schedules-list"))

     ,(tab "text-question-html"
       `(:h2 :class "text-center question-html" "Dies ist eine Testfrage?")
       `(:div :class "row justify-content-center"
          (:div :class "col col-sm-10 col-md-6"
                   (:div :id "answers-html" " "
                      (:input :type "text" :class "form-control" :id "text-response"))
                   (:button :type "button" :class "btn btn-primary mt-1 text-submit-html"
                         "Absenden")
                   (:button :type "button" :class
                         "btn btn-primary mt-1 next-question d-none" "Nächste Frage"))))

     (:div :class
      "container my-tab position-absolute col-sm-6 offset-sm-3 col-md-4 offset-md-4 text-center d-none"
      :id "login" (:h1 "Anmelden")
      (:form :id "login-form"
       ,(text-input "Name" "inputName" "username" :required t :autofocus t :autocomplete "username" :no-label? t)
       (:div :class "form-group"
                (:input :type "password" :id "inputPassword" :name "password" :class "form-control"
                     :placeholder "Passwort" :required "" :autocomplete
                     "current-password"))
       ,(submit-button "Anmelden" :id "login-button")))

     ,(tab "page"
       `(:div :class "alert alert-warning mt-1 d-none" :id "is-outdated-article"
          :role "alert"
          " Dies zeigt den Artikel zu einem bestimmten Zeitpunkt und ist somit nicht unbedingt aktuell! "
          (:a :href "#" :id "currentVersionLink" :class "alert-link "
                 "Zur aktuellen Version"))
       `(:h1 :class "text-center" :id "wiki-article-title" "title")
       `(:div :class "article-editor"
          (:div :id "editor" :class "d-none"
                   (:a :href "#" :id "format-p" (:span :class "fas fa-paragraph")) " "
                   (:a :href "#" :id "format-h2" (:span :class "fas fa-heading")) " "
                   (:a :href "#" :id "format-h3" (:span :class "fas fa-heading")) " "
                   (:a :href "#" :id "superscript" (:span :class "fas fa-superscript")) " "
                   (:a :href "#" :id "subscript" (:span :class "fas fa-subscript")) " "
                   (:a :href "#" :id "insertUnorderedList" (:span :class "fas fa-list-ul")) " "
                   (:a :href "#" :id "insertOrderedList" (:span :class "fas fa-list-ol")) " "
                   (:a :href "#" :id "indent" (:span :class "fas fa-indent")) " "
                   (:a :href "#" :id "outdent" (:span :class "fas fa-outdent")) " "
                   (:a :href "#" :id "createLink" (:span :class "fas fa-link")) " "
                   (:a :href "#" :id "insertImage" (:span :class "fas fa-image")) " "
                   (:a :href "#" :id "table" (:span :class "fas fa-table")) " "
                   (:a :href "#" :id "undo" (:span :class "fas fa-undo")) " "
                   (:a :href "#" :id "redo" (:span :class "fas fa-redo")) " "
                   (:a :href "#" :id "settings" (:span :class "fas fa-cog")) " "
                   (:a :href "#" :id "finish" (:span :class "fas fa-check")))
          (:article))
       `(:div :id "categories")
       `(:div
           (:button :id "show-history" :type "button" :class
                "btn btn-outline-primary" "Änderungsverlauf"))
       `(:small "Dieses Werk ist lizenziert unter einer "
            ,(license)))

     ,(tab "not-found"
       `(:div :class "alert alert-danger" :role "alert"
          " Der Artikel konnte nicht gefunden werden. Möchtest du ihn "
          (:a :id "create-article" :href "#" :class "alert-link" "erstellen")
          "?"))

     ,(tab "history"
       `(:h1 :class "text-center" "Änderungsverlauf")
       `(:div :class "list-group" :id "history-list"))

     ,(tab "search"
       `(:div :class "input-group mb-3"
          (:input :type "text" :class "form-control" :id "search-query"
               :placeholder "Suchbegriff")
          (:div :class "input-group-append"
                   (:button :class "btn btn-outline-secondary" :type "button" :id
                         "button-search" (:i :class "fas fa-search"))))
       `(:div
           (:div :style "left: 50%; margin-left: -1rem;" :class
             "position-absolute d-none" :id "search-results-loading"
             (:div :class "spinner-border" :role "status"
                      (:span :class "sr-only" "Loading...")))
           (:div :class "d-none" :id "search-results"
             (:div :class "text-center d-none" :id
                      "no-search-results"
                      (:div :class "alert alert-warning" :role "alert"
                         " Es konnte kein Artikel mit genau diesem Titel gefunden werden. Möchtest du ihn "
                         (:a :id "search-create-article" :href "#" :class "alert-link "
                           "erstellen")
                         "?"))
             (:div :class "list-group" :id "search-results-content"))))

     (:div :class "my-tab position-absolute" :style
      "top: 50%; left: 50%; margin-left: -1rem; margin-top: -1rem;" :id
      "loading"
      (:div :class "spinner-border" :role "status"
              (:span :class "sr-only" "Loading...")))

     ,(tab "error"
       `(:div :class "alert alert-danger" :role "alert"
          (:span :id "errorMessage") " "
          (:a :href "#" :id "refresh" :class "alert-link" "Erneut versuchen")))

     ,(modal "publish-changes" "Änderungen veröffentlichen"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss
            "modal" "Bearbeitung fortsetzen")
          (:button :type "button" :class "btn btn-primary" :id "publish-changes"
            "Änderungen veröffentlichen"))
        `((:div :class "form-group" " " (:label "Änderungszusammenfassung:")
           (:br)
           (:textarea :class "form-control" :id "change-summary" :rows "3"))
          ,(license-disclaimer)))

     ,(modal "wiki-link" "Spickipedia-Link einfügen"
        `((:button :type "button" :class "btn btn-primary"
            "Änderungen veröffentlichen"))
        `(,(text-input "Anzeigetext" "article-link-text" "link-text")
           ,(text-input "Spickipedia-Artikel" "article-link-title" "link-title")))

     ,(modal "settings" "Kategorien"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss
            "modal" "Fertig"))
        `(,(text-input "Kategorie..." "new-category" "category" :no-label? t)))

     ,(modal "create-link" "Link erstellen"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss "modal" "Abbrechen")
          ,(submit-button "Ok"))
        `((:div :class "form-group" :style "position: relative; display: inline-block;"
           (:input :type "text" :id "create-link" :class "form-control link-input" :autocomplete "off")
           (:div :class "dropdown-menu" :style "position: absolute; top: 100%; left: 0px; z-index: 100; width: 100%;"))))

      ,(modal "edit-link" "Link ändern"
         `((:button :type "button" :class "btn btn-secondary" :data-dismiss "modal" "Abbrechen")
           ,(submit-button "Ok"))
         `((:div :class "form-group" :style "position: relative; display: inline-block;"
            (:input :type "text" :id "edit-link" :class "form-control link-input" :autocomplete "off")
            (:div :class "dropdown-menu" :style "position: absolute; top: 100%; left: 0px; z-index: 100; width: 100%;"))))

     ,(modal "table" "Tabelle"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss
            "modal" "Abbrechen")
          (:button :type "button" :class "btn btn-primary" :id "update-table"
            "Ok"))
        `((:div :class "form-group" (:label :for "table-columns" "Spalten:")
           (:input :type "number" :id "table-columns" :class "form-control"))
          (:div :class "form-group" (:label :for "table-rows" "Zeilen:") " "
           (:input :type "number" :id "table-rows" :class "form-control"))))

     ,(modal "image" "Bild"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss
            "modal" "Abbrechen")
          (:button :type "button" :class "btn btn-primary" :id "update-image"
            "Ok"))
        `((:div :class "form-group"
           (:label :for "image-file" "Bild auswählen:")
           (:input :type "file" :accept "image/*" :class "form-control-file"
                :id "image-file"))
          (:div :class "form-group" (:label :for "image-url" "Bild-URL:")
           (:input :type "url" :id "image-url" :class "form-control"))))

     ,(modal "formula" "Formel"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss
            "modal" "Abbrechen")
          (:button :type "button" :class "btn btn-primary" :id "update-formula"
            "Ok"))
        `((:div :class "form-group"
           (:div :class "alert alert-warning" :role "alert" "Formeln editieren funktioniert nur in Google Chrome zuverlässig!")
           (:span :id "formula" "e=mc^2"))))

     (:script :src "/popper.js")
     (:script :src "/bootstrap.js")
     (:script :type "module" :src "/js/index.lisp")
     (:link :rel "stylesheet" :href "/mathlive.core.css")
     (:link :rel "stylesheet" :href "/mathlive.css"))))
#|
(:script :src "/visual-diff.js")
|#
