(in-package :spickipedia.web)

(defun modal (base-id title footer body)
  `(:DIV :CLASS "modal fade" :ID ,(concatenate 'string "modal-" base-id) :TABINDEX "-1" :ROLE "dialog" :ARIA-HIDDEN "true"
     (:DIV :CLASS "modal-dialog" :ROLE "document"
      (:DIV :CLASS "modal-content"
        (:form :method "POST" :id ,(concatenate 'string "form-" base-id)
          (:DIV :CLASS "modal-header"
           (:H5 :CLASS "modal-title" ,title)
           (:BUTTON :TYPE "button" :CLASS "close" :DATA-DISMISS "modal" :ARIA-LABEL
            "Close" " " (:SPAN :ARIA-HIDDEN "true" "×")))
          (:DIV :CLASS "modal-body"
           ,@body)
          (:DIV :CLASS "modal-footer"
           ,@footer))))))

(defun teacher-select (id)
  `(:DIV :CLASS "form-group"
    (:label "LehrerIn")
    (:select :CLASS "custom-select teacher-select" :id ,id :name "teacher"
      (:option "Wird geladen..."))))

(defun text-input (label id name)
  `(:DIV :CLASS "form-group"
     (:label ,label)
     (:INPUT :TYPE "text" :CLASS "form-control" :PLACEHOLDER ,label :name ,name :id ,id)))

(defun checkbox-input (label id name)
  `(:div :class "custom-control custom-checkbox"
    (:input :type "checkbox" :class "custom-control-input" :name ,name :id ,id)
    (:label :class "custom-control-label" :for ,id ,label)))

(defun submit-button (label)
  `(:BUTTON :TYPE "submit" :CLASS
     "btn btn-primary"
     ,label))

(defun tab (id &rest content)
  `(:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id ,id
     ,@content))
