(:HTML :LANG "en"
 (:HEAD (:META :CHARSET "utf-8")
  (:META :NAME "viewport" :CONTENT
   "width=device-width, initial-scale=1, shrink-to-fit=no")
  (:LINK :REL "stylesheet" :HREF "/bootstrap.min.css")
  (:LINK :REL "stylesheet" :HREF "/all.css")
  (:LINK :REL "stylesheet" :HREF "/index.css")

  (:LINK :REL "modulepreload" :HREF "/js/index.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/test.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/replace-state.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/update-state.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/push-state.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/editor-lib.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/register-sw.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/wiki.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/search.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/quiz.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/logout.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/login.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/root.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/history.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/edit.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/create.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/articles.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/show-tab.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/categories.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/file-upload.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/cleanup.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/handle-error.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/math.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/image-viewer.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/read-cookie.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/get-url-parameter.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/editor.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/hide-editor.lisp")
  (:LINK :REL "modulepreload" :HREF "/js/teachers.lisp")
  (:LINK :REL "preload" :AS "font" :crossorigin "" :type "font/woff2" :href "/webfonts/fa-solid-900.woff2")

  (:TITLE "Spickipedia"))
 (:BODY
  (:TEMPLATE :ID "multiple-choice-answer-html"
   (:DIV :CLASS "custom-control custom-checkbox" " "
    (:INPUT :TYPE "checkbox" :CLASS "custom-control-input" :ID "customCheck1")
    (:LABEL :CLASS "custom-control-label" :FOR "customCheck1"
     "Check this custom")))

  (:template :id "teachers-list-html"
    (:li :class "teachers-list-name"))

  (:template :id "courses-list-html"
    (:li :class "courses-list-subject"))

  (:TEMPLATE :ID "multiple-choice-question"
   (:DIV :CLASS "multiple-choice-question"
    (:FORM
     (:DIV :CLASS "form-group"
      (:INPUT :TYPE "text" :CLASS "form-control question" :PLACEHOLDER
       "Frage eingeben"))
     (:DIV :CLASS "responses")
     (:BUTTON :TYPE "button" :CLASS
      "btn btn-primary mb-1 add-response-possibility"
      "Antwortmöglichkeit hinzufügen"))
    (:HR)))

  (:TEMPLATE :ID "text-question"
   (:DIV :CLASS "text-question"
    (:FORM
     (:DIV :CLASS "form-group"
      (:INPUT :TYPE "text" :CLASS "form-control question" :PLACEHOLDER
       "Frage eingeben"))
     (:DIV :CLASS "form-group"
      (:INPUT :TYPE "text" :CLASS "form-control answer" :PLACEHOLDER
       "Antwort eingeben")))
    (:HR)))

  (:TEMPLATE :ID "multiple-choice-response-possibility"
   (:DIV :CLASS "input-group mb-3"
    (:DIV :CLASS "input-group-prepend"
     (:DIV :CLASS "input-group-text"
      (:INPUT :CLASS "multiple-choice-response-correct" :TYPE "checkbox"
       :ARIA-LABEL "Checkbox for following text input")))
    (:INPUT :TYPE "text" :CLASS "form-control multiple-choice-response-text"
     :ARIA-LABEL "Text input with checkbox")))

  (:TEMPLATE :ID "search-result-template"
   (:A :CLASS "list-group-item list-group-item-action"
    (:DIV
     (:DIV (:H5 :CLASS "mt-0 s-title" "Media heading")
      (:DIV :CLASS "search-result-summary word-wrap")))))

  (:TEMPLATE :ID "history-item-template" " "
   (:DIV :CLASS "list-group-item list-group-item-action"
    (:DIV :CLASS "d-flex w-100 justify-content-between"
     (:H5 :CLASS "mb-1 history-username" "Moritz Hedtke")
     (:SMALL :CLASS "history-date" "vor 3 Tagen"))
    (:P :CLASS "mb-1 history-summary" "Ein paar wichtige Infos hinzugefügt")
    (:SMALL (:SPAN :CLASS "history-characters" "50.322") " Zeichen"
     (:SPAN :CLASS "text-success d-none" "+ 50 Zeichen"))
    (:DIV :CLASS "btn-group w-100" :ROLE "group" :ARIA-LABEL "Basic example"
     (:A :TYPE "button" :CLASS "btn btn-outline-dark history-show"
      (:I :CLASS "fas fa-eye"))
     (:A :TYPE "button" :CLASS "btn btn-outline-dark history-diff"
      (:I :CLASS "fas fa-columns")))))

  (:TEMPLATE :ID "articles-entry" (:LI (:A :CLASS "" :HREF "#" "Hauptseite")))

  (:NAV :CLASS "navbar navbar-expand-md navbar-light bg-light"
   (:A :CLASS "navbar-brand " :HREF "/wiki/Hauptseite" "Spickipedia ")
   (:DIV :CLASS "login-hide"
    (:A :CLASS "btn d-inline d-md-none edit-button" (:I :CLASS "fas fa-pen"))
    (:A :CLASS "btn d-inline d-md-none search-button " :HREF "/search"
     (:I :CLASS "fas fa-search"))
    (:BUTTON :CLASS "navbar-toggler" :TYPE "button" :DATA-TOGGLE "collapse"
     :DATA-TARGET "#navbarSupportedContent" :ARIA-CONTROLS
     "navbarSupportedContent" :ARIA-EXPANDED "false" :ARIA-LABEL
     "Toggle navigation" (:SPAN :CLASS "navbar-toggler-icon")))
   (:DIV :CLASS "collapse navbar-collapse" :ID "navbarSupportedContent"
    (:UL :CLASS "navbar-nav mr-auto"
     (:LI :CLASS "nav-item d-none d-md-block"
      (:A :CLASS "nav-link search-button " :HREF "/search" "Suchen"))
     (:LI :CLASS "nav-item d-none d-md-block"
      (:A :CLASS "nav-link edit-button" :HREF "#" "Bearbeiten"))
     (:LI :CLASS "nav-item"
      (:A :CLASS "nav-link " :HREF "/logout" :ID "logout" "Abmelden")))))

  (:DIV
   (:DIV :STYLE "display: none;" :CLASS "container my-tab position-absolution"
    :ID "edit-quiz" (:H1 :CLASS "text-center" "Quiz ändern")
    (:DIV :ID "questions")
    (:BUTTON :TYPE "button" :CLASS
     "btn btn-primary mb-1 create-multiple-choice-question"
     "Multiple-Choice-Frage hinzufügen")
    (:BUTTON :TYPE "button" :CLASS "btn btn-primary mb-1 create-text-question"
     "Frage mit Textantwort hinzufügen")
    (:BUTTON :TYPE "button" :CLASS "btn btn-primary mb-1 save-quiz"
     "Speichern")))

  (:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id "create-course-tab"
    (:FORM :method "POST" :action "/api/courses" :id "create-course-form"
     (:DIV :CLASS "form-group"
      (:label "Fach")
      (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Fach" :name "subject"))
     (:DIV :CLASS "form-group"
       (:label "Typ")
       (:select :CLASS "custom-select" :name "type"
         (:option :selected "true" "GK")
         (:option "LK")))
     (:DIV :CLASS "form-group"
       (:label "LehrerIn")
       (:select :CLASS "custom-select" :id "teachers-select" :name "teacher"
         (:option "Wird geladen...")))
     (:div :class "custom-control custom-checkbox"
       (:input :type "checkbox" :class "custom-control-input" :name "is-tutorial" :id "is-tutorial")
       (:label :class "custom-control-label" :for "is-tutorial" "Tutorium?"))
     (:DIV :CLASS "form-group"
      (:label "Klasse")
      (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Klasse" :name "class"))
     (:DIV :CLASS "form-group"
      (:label "Thema")
      (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Thema" :name "topic"))

     (:BUTTON :TYPE "submit" :CLASS
      "btn btn-primary"
      "Kurs erstellen")))

  (:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id "create-teacher-tab"
    (:FORM :method "POST" :action "/api/teachers" :id "create-teacher-form"
     (:DIV :CLASS "form-group"
      (:label "Name")
      (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Name" :name "name"))
     (:DIV :CLASS "form-group"
      (:label "Initialien")
      (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Initialien" :name "initial"))
     (:BUTTON :TYPE "submit" :CLASS
      "btn btn-primary"
      "LehrerIn erstellen")))

  (:DIV :STYLE "display: none;" :CLASS "container my-tab position-absolute" :ID "articles"
    (:H1 :CLASS "text-center" "Alle Artikel")
    (:UL :ID "articles-list"))

  (:div :style "display: none;" :class "container my-tab position-absolute" :id "tags"
    (:h1 :class "text-center" "Tags")
    (:ul :id "tags-list"))

  (:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id "create-schedule-tab"
    (:FORM :method "POST" :action "/api/schedules" :id "create-schedule-form"
     (:DIV :CLASS "form-group"
      (:label "Klasse")
      (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER "Klasse" :name "clazz"))
     (:BUTTON :TYPE "submit" :CLASS
      "btn btn-primary"
      "Stundenplan erstellen")))

  (:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id "schedule"
    (:div :class "table-responsive"
      (:table :class "table table-hover table-bordered table-dark table-sm"
        (:thead
          (:tr
            (:th :scope "col" "#")
            (:th :scope "col" "Montag")
            (:th :scope "col" "Dienstag")
            (:th :scope "col" "Mittwoch")
            (:th :scope "col" "Donnerstag")
            (:th :scope "col" "Freitag")))
        (:tbody
          (:tr
            (:th :scope "row" "1")
            (:td "a")
            (:td "a")
            (:td "a")
            (:td "a")
            (:td "a"))))))


  (:DIV :STYLE "display: none;" :CLASS "container my-tab position-absolute" :ID
   "multiple-choice-question-html"
   (:H2 :CLASS "text-center question-html" "Dies ist eine Testfrage?")
   (:DIV :CLASS "row justify-content-center"
    (:DIV :CLASS "col col-sm-10 col-md-6" (:DIV :ID "answers-html")
     (:BUTTON :TYPE "button" :CLASS
      "btn btn-primary mt-1 multiple-choice-submit-html" "Absenden")
     (:BUTTON :TYPE "button" :STYLE "display: none;" :CLASS
      "btn btn-primary mt-1 next-question" "Nächste Frage"))))

  (:DIV :STYLE "display: none;" :CLASS "container my-tab position-absolute" :ID
   "quiz-results" (:H1 :CLASS "text-center" "Ergebnisse") (:P :ID "result"))

  (:DIV :STYLE "display: none;" :class "container my-tab position-absolute" :ID "list-teachers"
    (:h2 :class "text-center" "Lehrer")
    (:ul :id "teachers-list"))

  (:div :style "display: none;" :class "container my-tab position-absolute" :id "list-courses"
   (:h2 :class "text-center" "Kurse")
   (:ul :id "courses-list"))

  (:DIV :STYLE "display: none;" :CLASS "container my-tab position-absolute" :ID
   "text-question-html"
   (:H2 :CLASS "text-center question-html" "Dies ist eine Testfrage?")
   (:DIV :CLASS "row justify-content-center"
    (:DIV :CLASS "col col-sm-10 col-md-6"
     (:DIV :ID "answers-html" " "
      (:INPUT :TYPE "text" :CLASS "form-control" :ID "text-response"))
     (:BUTTON :TYPE "button" :CLASS "btn btn-primary mt-1 text-submit-html"
      "Absenden")
     (:BUTTON :TYPE "button" :STYLE "display: none;" :CLASS
      "btn btn-primary mt-1 next-question" "Nächste Frage"))))

  (:DIV :STYLE "display: none;" :CLASS
   "container my-tab position-absolute col-sm-6 offset-sm-3 col-md-4 offset-md-4 text-center"
   :ID "login" (:H1 "Anmelden")
   (:FORM :ID "login-form"
    (:DIV :CLASS "form-group"
     (:INPUT :TYPE "text" :ID "inputName" :CLASS "form-control" :PLACEHOLDER
      "Name" :REQUIRED "" :AUTOFOCUS ""))
    (:DIV :CLASS "form-group"
     (:INPUT :TYPE "password" :ID "inputPassword" :CLASS "form-control"
      :PLACEHOLDER "Passwort" :REQUIRED ""))
    (:BUTTON :CLASS "btn btn-primary" :TYPE "submit" :ID "login-button"
     "Anmelden")))

  (:DIV :STYLE "display: none;" :CLASS
   "container-fluid my-tab position-absolute word-wrap" :ID "page"
   (:DIV :CLASS "alert alert-warning mt-1 d-none" :ID "is-outdated-article"
    :ROLE "alert"
    " Dies zeigt den Artikel zu einem bestimmten Zeitpunkt und ist somit nicht unbedingt aktuell! "
    (:A :HREF "#" :ID "currentVersionLink" :CLASS "alert-link "
     "Zur aktuellen Version"))
   (:H1 :CLASS "text-center" :ID "wiki-article-title" "title")
   (:DIV :CLASS "article-editor"
    (:DIV :ID "editor" :CLASS "d-none"
     (:A :HREF "#" :ID "format-p" (:SPAN :CLASS "fas fa-paragraph")) " "
     (:A :HREF "#" :ID "format-h2" (:SPAN :CLASS "fas fa-heading")) " "
     (:A :HREF "#" :ID "format-h3" (:SPAN :CLASS "fas fa-heading")) " "
     (:A :HREF "#" :ID "superscript" (:SPAN :CLASS "fas fa-superscript")) " "
     (:A :HREF "#" :ID "subscript" (:SPAN :CLASS "fas fa-subscript")) " "
     (:A :HREF "#" :ID "insertUnorderedList" (:SPAN :CLASS "fas fa-list-ul")) " "
     (:A :HREF "#" :ID "insertOrderedList" (:SPAN :CLASS "fas fa-list-ol")) " "
     (:A :HREF "#" :ID "indent" (:SPAN :CLASS "fas fa-indent")) " "
     (:A :HREF "#" :ID "outdent" (:SPAN :CLASS "fas fa-outdent")) " "
     (:A :HREF "#" :ID "createLink" (:SPAN :CLASS "fas fa-link")) " "
     (:A :HREF "#" :ID "insertImage" (:SPAN :CLASS "fas fa-image")) " "
     (:A :HREF "#" :ID "table" (:SPAN :CLASS "fas fa-table")) " "
     (:A :HREF "#" :ID "insertFormula" (:SPAN :CLASS "fas fa-calculator")) " "
     (:A :HREF "#" :ID "undo" (:SPAN :CLASS "fas fa-undo")) " "
     (:A :HREF "#" :ID "redo" (:SPAN :CLASS "fas fa-redo")) " "
     (:A :HREF "#" :ID "settings" (:SPAN :CLASS "fas fa-cog")) " "
     (:A :HREF "#" :ID "finish" (:SPAN :CLASS "fas fa-check")))
    (:ARTICLE))
   (:DIV :ID "categories")
   (:DIV
    (:BUTTON :ID "show-history" :TYPE "button" :CLASS "btn btn-outline-primary"
     "Änderungsverlauf"))
   (:SMALL "Dieses Werk ist lizenziert unter einer "
    (:A :TARGET "_blank" :REL "license noopener" :HREF
     "http://creativecommons.org/licenses/by-sa/4.0/deed.de"
     "Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz")
    "."))

  (:DIV :STYLE "display: none;" :CLASS
   "container-fluid my-tab position-absolute" :ID "not-found"
   (:DIV :CLASS "alert alert-danger" :ROLE "alert"
    " Der Artikel konnte nicht gefunden werden. Möchtest du ihn "
    (:A :ID "create-article" :HREF "#" :CLASS "alert-link" "erstellen") "?"))

  (:DIV :STYLE "display: none;" :CLASS
   "container-fluid my-tab position-absolute" :ID "history"
   (:H1 :CLASS "text-center" "Änderungsverlauf")
   (:DIV :CLASS "list-group" :ID "history-list"))

  (:DIV :STYLE "display: none;" :CLASS
   "container-fluid my-tab position-absolute" :ID "search" " " (:BR)
   (:DIV :CLASS "input-group mb-3"
    (:INPUT :TYPE "text" :CLASS "form-control" :ID "search-query" :PLACEHOLDER
     "Suchbegriff")
    (:DIV :CLASS "input-group-append"
     (:BUTTON :CLASS "btn btn-outline-secondary" :TYPE "button" :ID
      "button-search" (:I :CLASS "fas fa-search"))))
   (:DIV
    (:DIV :STYLE "display: none; left: 50%; margin-left: -1rem;" :CLASS
     "position-absolute" :ID "search-results-loading"
     (:DIV :CLASS "spinner-border" :ROLE "status"
      (:SPAN :CLASS "sr-only" "Loading...")))
    (:DIV :STYLE "display: none;" :ID "search-results"
     (:DIV :STYLE "display: none;" :CLASS "text-center" :ID "no-search-results"
      (:DIV :CLASS "alert alert-warning" :ROLE "alert"
       " Es konnte kein Artikel mit genau diesem Titel gefunden werden. Möchtest du ihn "
       (:A :ID "search-create-article" :HREF "#" :CLASS "alert-link "
        "erstellen")
       "?"))
     (:DIV :CLASS "list-group" :ID "search-results-content"))))

  (:DIV :CLASS "my-tab position-absolute" :STYLE
   "top: 50%; left: 50%; margin-left: -1rem; margin-top: -1rem;" :ID "loading"
   (:DIV :CLASS "spinner-border" :ROLE "status"
    (:SPAN :CLASS "sr-only" "Loading...")))

  (:DIV :STYLE "display: none;" :CLASS
   "container-fluid my-tab position-absolute" :ID "error"
   (:DIV :CLASS "alert alert-danger" :ROLE "alert"
    (:SPAN :ID "errorMessage") " "
    (:A :HREF "#" :ID "refresh" :CLASS "alert-link" "Erneut versuchen")))

  (:DIV :CLASS "modal fade" :ID "publish-changes-modal" :TABINDEX "-1" :ROLE
   "dialog" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-header"
      (:H5 :CLASS "modal-title" "Änderungen veröffentlichen")
      (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
       "Close" " " (:SPAN :ARIA-HIDDEN "true" "×")))
     (:DIV :CLASS "modal-body"
      (:FORM
       (:DIV :CLASS "form-group" " " (:LABEL "Änderungszusammenfassung:") (:BR)
        (:TEXTAREA :CLASS "form-control" :ID "change-summary" :ROWS "3")))
      (:P
       "Mit dem Veröffentlichen dieses Artikels garantierst du, dass er nicht die Rechte anderer verletzt und bist damit einverstanden, ihn unter der "
       (:A :TARGET "_blank" :REL "noopener" :HREF
        "https://creativecommons.org/licenses/by-sa/4.0/deed.de"
        "Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz")
       " zu veröffentlichen."))
     (:DIV :CLASS "modal-footer"
      (:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
       "Bearbeitung fortsetzen")
      (:BUTTON :TYPE "button" :CLASS "btn btn-primary" :ID "publish-changes"
       "Änderungen veröffentlichen")
      (:BUTTON :ID "publishing-changes" :CLASS "btn btn-primary" :STYLE
       "display: none;" :TYPE "button" :DISABLED "" " "
       (:SPAN :CLASS "spinner-border spinner-border-sm" :ROLE "status"
        :ARIA-HIDDEN "true")
       " Veröffentlichen... ")))))

  (:DIV :CLASS "modal fade" :ID "uploadProgressModal" :TABINDEX "-1" :ROLE
   "dialog" :ARIA-LABELLEDBY "exampleModalCenterTitle" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog modal-dialog-centered" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-body"
      (:DIV :CLASS "progress"
       (:DIV :ID "uploadProgress" :CLASS
        "progress-bar progress-bar-striped progress-bar-animated" :ROLE
        "progressbar" :ARIA-VALUENOW "75" :ARIA-VALUEMIN "0" :ARIA-VALUEMAX
        "100" :STYLE "width: 0%"))))))

  (:DIV :CLASS "modal fade" :ID "spickiLinkModal" :TABINDEX "-1" :ROLE "dialog"
   :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-header"
      (:H5 :CLASS "modal-title" "Spickipedia-Link einfügen")
      (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
       "Close" (:SPAN :ARIA-HIDDEN "true" "×")))
     (:DIV :CLASS "modal-body"
      (:FORM
       (:DIV :CLASS "form-group" (:LABEL "Anzeigetext") (:BR)
        (:INPUT :CLASS "form-control" :TYPE "text" :ID "article-link-text")
        "<input>")
       (:DIV :CLASS "form-group" (:LABEL "Spickipedia-Artikel") (:BR)
        (:INPUT :CLASS "form-control" :TYPE "text" :ID "article-link-title")
        "<input>")))
     (:DIV :CLASS "modal-footer"
      (:BUTTON :TYPE "button" :CLASS "btn btn-primary" :ID "publish-changes"
       "Änderungen veröffentlichen")))))

  (:DIV :CLASS "modal fade" :ID "settings-modal" :TABINDEX "-1" :ROLE "dialog"
   :ARIA-LABELLEDBY "exampleModalLabel" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-header"
      (:H5 :CLASS "modal-title" :ID "exampleModalLabel" "Kategorien") " "
      (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
       "Fertig" " " (:SPAN :ARIA-HIDDEN "true" "×")))
     (:DIV :CLASS "modal-body"
      (:FORM :CLASS "form-inline" :ID "add-tag-form"
       (:INPUT :ID "new-category" :CLASS "form-control form-control-sm" :TYPE
        "text" :PLACEHOLDER "Kategorie...")))
     (:DIV :CLASS "modal-footer"
      (:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
       "Fertig")))))

  (:DIV :CLASS "modal fade" :ID "link-modal" :TABINDEX "-1" :ROLE "dialog"
   :ARIA-LABELLEDBY "exampleModalLabel" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:FORM :ID "link-form"
      (:DIV :CLASS "modal-header"
       (:H5 :CLASS "modal-title" :ID "exampleModalLabel" "Link")
       (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
        "Close" (:SPAN :ARIA-HIDDEN "true" "×")))
      (:DIV :CLASS "modal-body"
        (:DIV :CLASS "form-group" :style "position: relative; display: inline-block;"
          (:INPUT :TYPE "text" :ID "link" :CLASS "form-control" :autocomplete "off")
          (:div :class "dropdown-menu" :style "position: absolute; top: 100%; left: 0px; z-index: 100; width: 100%;")))
      (:DIV :CLASS "modal-footer"
       (:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
        "Abbrechen")
       (:BUTTON :TYPE "submit" :CLASS "btn btn-primary" :ID "update-link"
        "Ok"))))))

  (:DIV :CLASS "modal fade" :ID "table-modal" :TABINDEX "-1" :ROLE "dialog"
   :ARIA-LABELLEDBY "exampleModalLabel" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-header"
      (:H5 :CLASS "modal-title" :ID "exampleModalLabel" "Tabelle")
      (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
       "Close" (:SPAN :ARIA-HIDDEN "true" "×")))
     (:DIV :CLASS "modal-body"
      (:FORM
       (:DIV :CLASS "form-group" (:LABEL :FOR "table-columns" "Spalten:")
         (:INPUT :TYPE "number" :ID "table-columns" :CLASS "form-control"))
       (:DIV :CLASS "form-group" (:LABEL :FOR "table-rows" "Zeilen:") " "
        (:INPUT :TYPE "number" :ID "table-rows" :CLASS "form-control"))))
     (:DIV :CLASS "modal-footer"
      (:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
       "Abbrechen")
      (:BUTTON :TYPE "button" :CLASS "btn btn-primary" :ID "update-table"
       "Ok")))))

  (:DIV :CLASS "modal fade" :ID "image-modal" :TABINDEX "-1" :ROLE "dialog"
   :ARIA-LABELLEDBY "exampleModalLabel" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-header"
      (:H5 :CLASS "modal-title" :ID "exampleModalLabel" "Bild")
      (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
       "Close" (:SPAN :ARIA-HIDDEN "true" "×")))
     (:DIV :CLASS "modal-body"
      (:FORM
       (:DIV :CLASS "form-group"
        (:DIV :CLASS "form-group"
         (:LABEL :FOR "image-file" "Bild auswählen:")
         (:INPUT :TYPE "file" :ACCEPT "image/*" :CLASS "form-control-file" :ID
          "image-file"))
        (:DIV :CLASS "form-group" (:LABEL :FOR "image-url" "Bild-URL:")
         (:INPUT :TYPE "url" :ID "image-url" :CLASS "form-control")))))
     (:DIV :CLASS "modal-footer"
      (:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
       "Abbrechen")
      (:BUTTON :TYPE "button" :CLASS "btn btn-primary" :ID "update-image"
       "Ok")))))

  (:DIV :CLASS "modal fade" :ID "formula-modal" :TABINDEX "-1" :ROLE "dialog"
   :ARIA-LABELLEDBY "exampleModalLabel" :ARIA-HIDDEN "true"
   (:DIV :CLASS "modal-dialog" :ROLE "document"
    (:DIV :CLASS "modal-content"
     (:DIV :CLASS "modal-header"
      (:H5 :CLASS "modal-title" :ID "exampleModalLabel" "Formel")
      (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
       "Close" (:SPAN :ARIA-HIDDEN "true" "×")))
     (:DIV :CLASS "modal-body"
      (:FORM
       (:DIV :CLASS "form-group"
        (:DIV :CLASS "alert alert-warning" :ROLE "alert"
         "Formeln editieren funktioniert nur in Google Chrome zuverlässig!")
        (:SPAN :ID "formula" "e=mc^2"))))
     (:DIV :CLASS "modal-footer"
      (:BUTTON :TYPE "button" :CLASS "btn btn-secondary" :DATA-DISMISS "modal"
       "Abbrechen")
      (:BUTTON :TYPE "button" :CLASS "btn btn-primary" :ID "update-formula"
       "Ok")))))

  (:SCRIPT :SRC "/jquery-3.3.1.js")
  ;; load later only when needed
  (:LINK :REL "stylesheet" :HREF "/mathlive.core.css")
  (:LINK :REL "stylesheet" :HREF "/mathlive.css")
  (:SCRIPT :SRC "/mathlive.js")
  (:SCRIPT :SRC "/popper.js")
  (:SCRIPT :SRC "/bootstrap.min.js")
  (:SCRIPT :SRC "/visual-diff.js")
  (:SCRIPT :NOMODULE "" :SRC "no_module_support.js")

  (:SCRIPT :TYPE "module" :SRC "/js/index.lisp")))
