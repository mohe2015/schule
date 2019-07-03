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
