
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
;; TODO accept arbitrary additional html attributes as keys
(defun text-input (label id name &key no-label? classes required autofocus autocomplete)
  `(:div :class "form-group"
    ,(if no-label? nil `(:label ,label))
    (:input :type "text" :class ,(concatenate 'string "form-control " classes) :placeholder ,label :name ,name
     :id ,id :required ,required :autofocus ,autofocus :autocomplete ,autocomplete)))
(defun checkbox-input (label id name)
  `(:div :class "custom-control custom-checkbox"
    (:input :type "checkbox" :class "custom-control-input" :name ,name :id ,id)
    (:label :class "custom-control-label" :for ,id ,label)))
(defun submit-button (label &key id)
  `(:button :type "submit" :class "btn btn-primary" :id ,id ,label))
(defun tab (id &rest content)
  `(:div :style "display: none;" :class
    "container-fluid my-tab position-absolute" :id ,id ,@content))
