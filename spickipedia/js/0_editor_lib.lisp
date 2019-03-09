;; TODO only do on edit path
;; TODO hide editor if not editing
;; TODO show editor in fullscreen
(setf (chain document (get-elements-by-tag-name "article") 0 content-editable) T)

(defmacro tool (id &body body)
    nil)

(chain
 document
 (get-element-by-id "format-p")
 (add-event-listener
  "click"
  (lambda (event)
    (chain event (prevent-default))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain document (exec-command "formatBlock" F "<p>"))
    F)))
