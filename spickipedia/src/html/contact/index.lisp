(in-package :spickipedia.web)

(defun contact-html ()
  (tab "tab-contact"
    `(:h2 :class "text-center" "Kontakt")
    `(:address
       (:strong "Moritz Hedtke") (:br)
       "Email: " (:a :href "mailto:Moritz.Hedtke@t-online.de" :target "_blank" "Moritz.Hedtke@t-online.de") (:br)
       "Telegram: " (:a :href "https://t.me/devmohe" :target "_blank" "@devmohe") (:br)
       "Instagram: " (:a :href "https://www.instagram.com/dev.mohe/" :target "_blank" "@dev.mohe") (:br)
       "Github: " (:a :href "https://github.com/mohe2015" :target "_blank" "@mohe2015") (:br)
       "WhatsApp: ..." (:br)
       "... oder persönlich")))
