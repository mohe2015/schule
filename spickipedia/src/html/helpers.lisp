
(in-package :spickipedia.web) 
(defun modal (base-id title footer body)
  `(:div :class "modal fade" :id ,(concatenate 'string "modal-" base-id)
    :tabindex "-1" :role "dialog" :aria-hidden "true"
    (:div :class "modal-dialog" :role "document"
     (:div :class "modal-content"
      (:form :method "POST" :id ,(concatenate 'string "form-" base-id)
       (:div :class "modal-header" (:h5 :class "modal-title" ,title)
        (:button :type "button" :class "close" :data-dismiss "modal"
         :aria-label "Close" " " (:span :aria-hidden "true" "×")))
       (:div :class "modal-body" ,@body)
       (:div :class "modal-footer" ,@footer)))))) 
(defun teacher-select (id)
  `(:div :class "form-group" (:label "LehrerIn")
    (:select :class "custom-select teacher-select" :id ,id :name "teacher"
     (:option "Wird geladen...")))) 
(defun text-input (label id name)
  `(:div :class "form-group" (:label ,label)
    (:input :type "text" :class "form-control" :placeholder ,label :name ,name
     :id ,id))) 
(defun checkbox-input (label id name)
  `(:div :class "custom-control custom-checkbox"
    (:input :type "checkbox" :class "custom-control-input" :name ,name :id ,id)
    (:label :class "custom-control-label" :for ,id ,label))) 
(defun submit-button (label)
  `(:button :type "submit" :class "btn btn-primary" ,label)) 
(defun tab (id &rest content)
  `(:div :style "display: none;" :class
    "container-fluid my-tab position-absolute" :id ,id ,@content)) 