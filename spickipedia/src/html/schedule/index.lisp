(in-package :spickipedia.web)

(defun schedule-tab (day)
  `(:div :class "tab-pane fade" :id ,day :role "tabpanel" :aria-labeledby
    ,(concatenate 'string day "-tab")
    (:table :class "table table-hover table-bordered table-dark table-sm"
     (:thead (:tr (:th :scope "col" "#") (:th :scope "col" "")))
     (:tbody
      (loop for i from 1 to 11
            do (htm
                (:tr (:td :class "min" (str i))
                 (:td
                  (:button :type "button" :class
                   "add-course btn btn-sm btn-outline-primary w-100"
                   (:span :class "fa fa-plus"))))))))))

(defun html-schedule ()
  `((:template :id "schedule-data-cell-template"
     (:div :class "mb-3 mt-3 schedule-data test"
      (:span :class "data" "Mathe LK Keller B201")
      (:div :class "nowrap"
       (:button :type "button" :class
        "btn btn-sm btn-outline-primary button-delete-schedule-data"
        (:span :class "fa fa-trash")))))
    (:template :id "schedule-data-static-cell-template"
	       (:div :class "mb-3 mt-3 schedule-data test"
		     (:span :class "data" "Mathe LK Keller B201")))
    ,(tab "schedule"
       `(:ul :id "schedule-tabs" :class "nav nav-tabs" :role "tablist"
          (:li :class "nav-item"
           (:a :class "nav-link schedule-tab-link" :id "monday-tab" :data-toggle "tab" :href
            "#monday" :role "tab" :aria-controls "monday" :aria-selected "true"
            "Montag"))
          (:li :class "nav-item"
           (:a :class "nav-link schedule-tab-link" :id "tuesday-tab" :data-toggle "tab" :href
            "#tuesday" :role "tab" :aria-controls "tuesday" :aria-selected "false"
            "Dienstag"))
          (:li :class "nav-item"
           (:a :class "nav-link schedule-tab-link" :id "wednesday-tab" :data-toggle "tab" :href
            "#wednesday" :role "tab" :aria-controls "wednesday" :aria-selected
            "false" "Mittwoch"))
          (:li :class "nav-item"
           (:a :class "nav-link schedule-tab-link" :id "thursday-tab" :data-toggle "tab" :href
            "#thursday" :role "tab" :aria-controls "thursday" :aria-selected
            "false" "Donnerstag"))
          (:li :class "nav-item"
           (:a :class "nav-link schedule-tab-link" :id "friday-tab" :data-toggle "tab" :href
            "#friday" :role "tab" :aria-controls "friday" :aria-selected "false"
            "Freitag"))

	  (:li :class "nav-item"
	       (:a :class "nav-link" :id "schedule-show-button" :href "" "Anzeigen"))
	  
	  (:li :class "nav-item"
	       (:a :class "nav-link" :id "schedule-edit-button" :href "edit" "Bearbeiten"))
	  
	  )
       `(:div :class "tab-content" :id "schedule-table"
          ,(schedule-tab "monday")
          ,(schedule-tab "tuesday") ,(schedule-tab "wednesday")
          ,(schedule-tab "thursday") ,(schedule-tab "friday")))

     ,(modal "schedule-data" "Unterrichtsstunde"
        `((:button :type "button" :class "btn btn-secondary" :data-dismiss
           "modal" "Abbrechen")
          ,(submit-button "Ok"))
        `((:input :type "hidden" :id "schedule-data-weekday" :name "weekday"
            :value "monday")
          (:input :type "hidden" :id "schedule-data-hour" :name "hour" :value
           "1")
          (:div :class "form-group"
           (:label :for "week-modulo" "Regelmäßigkeit")
           (:select :class "custom-select" :id "week-modulo" :name
            "week-modulo"
            (:option :selected "selected" :value "0" "Jede Woche")
            (:option :value "1" "Ungerade Woche")
            (:option :value "2" "Gerade Woche")))
          ,(course-select)
          ,(text-input "Raum" "room" "room")
          ,(license-disclaimer)))))
