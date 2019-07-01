(in-package :spickipedia.sanitize)

(define-sanitize-mode *sanitize-spickipedia*
    :elements ("h1" "h2" "h3" "h4" "h5" "h6" "p" "strike" "sub" "b" "u" "i" "sup" "table" "tbody" "tr" "td" "ul" "a" "br" "ol" "li" "img" "iframe" "span" "figure" "figcaption")

    :add-attributes (("a"      . (("rel" . "noopener noreferrer"))))

    :attributes ((:all          . ("class"))
                 ("h1"          . ("align" "style"))
                 ("h2"          . ("align" "style"))
                 ("h3"          . ("align" "style"))
                 ("h4"          . ("align" "style"))
                 ("h5"          . ("align" "style"))
                 ("h6"          . ("align" "style"))
                 ("a"           . ("href" "target"))
                 ("p"           . ("align" "style"))
                 ("img"         . ("src" "style"))
                 ("iframe"      . ("src" "width" "height"))) ;; TODO this needs to be checked correctly

    :protocols (("a"           . (("href" . (:ftp :http :https :mailto :relative))))
                ("img"         . (("src"  . (:http :https :relative))))
                ("iframe"      . (("src"  . (:http :https :relative)))))) ;; TODO only https ;; TODO better use a regex as it fails to detect the same protocol url //www.youtube.com
