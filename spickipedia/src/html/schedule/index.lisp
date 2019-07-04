(in-package :spickipedia.web)

(defun schedule-tab (day)
  `(:div :class "tab-pane fade" :id ,day :role "tabpanel" :aria-labeledby ,(concatenate 'string day "-tab")
    (:table :class "table table-hover table-bordered table-dark table-sm"
      (:thead
        (:tr
          (:th :scope "col" "#")
          (:th :scope "col" "")))
      (:tbody
        (loop for i from 1 to 11 do
          (cl-who:htm
              (:tr
                (:td (cl-who:str i))
                (:td (:button :type "button" :class "add-course btn btn-sm btn-outline-primary w-100"
                       (:span :class "fa fa-plus"))))))))))

(defun html-schedule ()
  `((:template :id "schedule-data-cell-template"
      (:div :class "mb-3 mt-3 schedule-data test"
       (:span :class "data" "Mathe LK Keller B201")
       (:div :class "nowrap"
         (:button :type "button" :class "btn btn-sm btn-outline-primary"
           (:span :class "fa fa-trash")))))

    (:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id "schedule"
      (:ul :id "schedule-tabs" :class "nav nav-tabs" :role "tablist"
        (:li :class "nav-item" (:a :class "nav-link" :id "monday-tab" :data-toggle "tab" :href "#monday" :role "tab" :aria-controls "monday" :aria-selected "true" "Montag"))
        (:li :class "nav-item" (:a :class "nav-link" :id "tuesday-tab" :data-toggle "tab" :href "#tuesday" :role "tab" :aria-controls "tuesday" :aria-selected "false" "Dienstag"))
        (:li :class "nav-item" (:a :class "nav-link" :id "wednesday-tab" :data-toggle "tab" :href "#wednesday" :role "tab" :aria-controls "wednesday" :aria-selected "false" "Mittwoch"))
        (:li :class "nav-item" (:a :class "nav-link" :id "thursday-tab" :data-toggle "tab" :href "#thursday" :role "tab" :aria-controls "thursday" :aria-selected "false" "Donnerstag"))
        (:li :class "nav-item" (:a :class "nav-link" :id "friday-tab" :data-toggle "tab" :href "#friday" :role "tab" :aria-controls "friday" :aria-selected "false" "Freitag")))
      (:div :class "tab-content" :id "schedule-table"
        ,(schedule-tab "monday")
        ,(schedule-tab "tuesday")
        ,(schedule-tab "wednesday")
        ,(schedule-tab "thursday")
        ,(schedule-tab "friday")))))
