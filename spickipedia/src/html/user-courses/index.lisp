(in-package :spickipedia.web)

(defun modal (id title footer body)
  `(:DIV :CLASS "modal fade" :ID ,id :TABINDEX "-1" :ROLE "dialog" :ARIA-HIDDEN "true"
     (:DIV :CLASS "modal-dialog" :ROLE "document"
      (:DIV :CLASS "modal-content"
       (:DIV :CLASS "modal-header"
        (:H5 :CLASS "modal-title" ,title)
        (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
         "Close" " " (:SPAN :ARIA-HIDDEN "true" "×")))
       (:DIV :CLASS "modal-body"
        ,@body)
       (:DIV :CLASS "modal-footer"
        ,@footer)))))

(defun html-user-courses ()
  `((:template :id "student-courses-list-html"
      (:li :class "student-courses-list-subject"))

    (:div :style "display: none;" :class "container my-tab position-absolute" :id "list-student-courses"
     (:h2 :class "text-center" "Deine Kurse" (:a :href "/student-courses/add" :type "button" :class "btn btn-primary norefresh" "+"))
     (:ul :id "student-courses-list"))

    ,(modal "student-courses-modal" "Kurs hinzufügen" nil
       `((:h2 :class "text-center" "Test")))))
