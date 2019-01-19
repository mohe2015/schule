(setf (@ window onerror) (lambda (message source lineno colno error)
			   (alert "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! ")))
