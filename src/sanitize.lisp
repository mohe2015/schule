(in-package :lisp-wiki)

(define-sanitize-mode *sanitize-spickipedia*
    :elements ("h1" "h2" "h3" "h4" "h5" "h6" "p" "strike" "sub" "b" "u" "i" "sup" "table" "tbody" "tr" "td" "ul" "a" "br" "ol" "li" "img" "iframe" "span")

    :add-attributes (("a"      . (("rel" . "noopener noreferrer"))))
    
    :attributes (("h1"          . ("align" "style"))
		 ("span"        . ("class"))
		 ("h2"          . ("align" "style"))
		 ("h3"          . ("align" "style"))
		 ("h4"          . ("align" "style"))
		 ("h5"          . ("align" "style"))
		 ("h6"          . ("align" "style"))
		 ("a"           . ("href" "target"))
		 ("p"           . ("align" "style"))
		 ("img"         . ("src" "style"))
		 ("table"       . ("class"))
		 ("iframe"      . ("src" "width" "height"))) ;; TODO this needs to be checked correctly

    :protocols (("a"           . (("href" . (:ftp :http :https :mailto :relative))))
                ("img"         . (("src"  . (:http :https :relative))))
		("iframe"      . (("src"  . (:http :https :relative))))) ;; TODO only https ;; TODO better use a regex as it fails to detect the same protocol url //www.youtube.com
    :css-attributes (("text-align" . ("center"))
		     ("float"      . ("left" "right"))
		     ("width")
		     ("height")
		     ("vertical-align")
		     ("top")
		     ("margin-right")))
