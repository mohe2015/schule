(import-default "./hide-editor.lisp" "hideEditor")

(export-default (defun cleanup ()
  (hide-editor)
  (chain ($ "#publish-changes-modal") (modal "hide"))
  (chain ($ "#publish-changes") (show))
  (chain ($ "#publishing-changes") (hide))))
