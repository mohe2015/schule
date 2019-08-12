(in-package :spickipedia.web)

(defun template-substitution-schedule ()
  `(,(tab "substitution-schedule")
     (:template
      :id "template-substitution-schedule"
      (:h1 :class "substitution-schedule-date text-center" "10.12.2001"))
     (:template
      :id "template-substitution-for-class"
      (:h2 :class "template-class text-center" "Q34"
	   (:ul)))
     (:template
      :id "template-substitution"
      (:li "Test ist frei!!!"))))
