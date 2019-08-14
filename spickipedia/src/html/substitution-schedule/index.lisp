(in-package :spickipedia.web)

(defun template-substitution-schedule ()
  `(,(tab "substitution-schedule"
	  `(:a :id "settings-enable-notifications" :type "button" :class "btn btn-primary norefresh disabled" "Benachrichtigungen aktivieren")
	  `(:div :id "substitution-schedule-content"))
     (:template
      :id "template-substitution-schedule"
      (:h1 :class "substitution-schedule-date text-center" "10.12.2001"))
     (:template
      :id "template-substitution-for-class"
      (:h2 :class "template-class text-center" "Q34")
      (:ul))
     (:template
      :id "template-substitution"
      (:li "Test ist frei!!!"))))
