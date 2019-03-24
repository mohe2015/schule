(import-default "./0_hide_editor.js" "hideEditor")

(export-default (defun cleanup ()
  (hide-editor)
  (chain ($ "#publish-changes-modal") (modal "hide"))
  (chain ($ "#publish-changes") (show))
  (chain ($ "#publishing-changes") (hide))))
