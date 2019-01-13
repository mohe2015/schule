(in-package :lisp-wiki)

(defparameter *default-cost* 13
  "The default value for the COST parameter to HASH.")

(defparameter *CATCH-ERRORS-P* nil) ;; TODO scan with this line enabled to find bugs
(defparameter *rewrite-for-session-urls* nil)
(defparameter *content-types-for-url-rewrite* nil)

;;(stop *acceptor*)

(defvar *acceptor* nil)

(if (not *acceptor*)
    (progn
      (defparameter *acceptor* (make-instance 'easy-acceptor :port 8888))
      (start *acceptor*)))

(defun random-base64 ()
  (usb8-array-to-base64-string (random-data 64)))

(defun wiki-page ()
  (ecase (request-method* *request*)
    (:GET (get-wiki-page))
    (:POST (post-wiki-page))))

(defget get-wiki-page
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if (not article)
	(progn
	  (setf (return-code* *reply*) 404)
	  (return-from get-wiki-page)))
    (let ((revision (mito:select-dao 'wiki-article-revision (where (:= :article article)) (order-by (:desc :id)) (limit 1))))
      (if (not revision)
	  (progn
	    (setf (return-code* *reply*) 404)
	    (return-from get-wiki-page)))
      (clean (wiki-article-revision-content (car revision)) *sanitize-spickipedia*))))

(defget wiki-revision-handler
  (let* ((id (subseq (script-name* *REQUEST*) 14))
	 (revision (mito:find-dao 'wiki-article-revision :id (parse-integer id))))
    (if (not revision)
	(progn
	  (setf (return-code*) 404)
	  (return-from wiki-revision-handler)))
    (clean (wiki-article-revision-content revision) *sanitize-spickipedia*)))

;; SELECT article_id FROM wiki_article_revision WHERE id = 8;
;; SELECT id FROM wiki_article_revision WHERE article_id = 1 and id < 8 ORDER BY id DESC LIMIT 1;
;; SELECT id FROM wiki_article_revision WHERE article_id = (SELECT article_id FROM wiki_article_revision WHERE id = 8) and id < 8 ORDER BY id DESC LIMIT 1;
(defget previous-revision-handler
  (let* ((id (parse-integer (subseq (script-name* *REQUEST*) 23)))
	 (query (dbi:prepare *connection* "SELECT id FROM wiki_article_revision WHERE article_id = (SELECT article_id FROM wiki_article_revision WHERE id = ?) and id < ? ORDER BY id DESC LIMIT 1;"))
	 (result (dbi:execute query id id))
	 (previous-id (getf (dbi:fetch result) :|id|)))
    (if previous-id
	(clean (wiki-article-revision-content (mito:find-dao 'wiki-article-revision :id previous-id)) *sanitize-spickipedia*)
	nil)))

(defpost post-wiki-page 
  (let* ((title (subseq (script-name* *REQUEST*) 10)) (article (mito:find-dao 'wiki-article :title title)))
    (if (not article)
	(setf article (mito:create-dao 'wiki-article :title title)))
    (mito:create-dao 'wiki-article-revision :article article :author user :summary (post-parameter "summary") :content (post-parameter "html" *request*))
    nil))

(defpost create-quiz-handler
    (format nil "~a"(object-id (mito:create-dao 'quiz :creator user))))

(defpost update-quiz-handler
  (let* ((quiz-id (parse-integer (subseq (script-name*) 10))))
    (create-dao 'quiz-revision :quiz (find-dao 'quiz :id quiz-id) :content (post-parameter "data") :author user)
    nil))
    
(defget wiki-page-history
  (setf (content-type*) "text/json")
  (let* ((title (subseq (script-name* *REQUEST*) 13)) (article (mito:find-dao 'wiki-article :title title)))
    (if article
	(json:encode-json-to-string
	 (mapcar #'(lambda (r) `((id   . ,(object-id r))
				 (user . ,(user-name (wiki-article-revision-author r)))
				 (summary . ,(wiki-article-revision-summary r))
				 (created . ,(local-time:format-timestring nil (mito:object-created-at r)))
				 (size    . ,(length (wiki-article-revision-content r)))))
		 (mito:select-dao 'wiki-article-revision (where (:= :article article)) (order-by (:desc :created-at)))))
	(progn
	  (setf (return-code* *reply*) 404)
	  nil))))

(defget search-handler
  (setf (content-type*) "text/json")
  (let* ((searchquery (tsquery-convert (subseq (script-name* *REQUEST*) 12)))
	 (query (dbi:prepare *connection* "SELECT a.title, ts_rank_cd((setweight(to_tsvector(a.title), 'A') || setweight(to_tsvector((SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1)), 'D')), query) AS rank, ts_headline(a.title || (SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1), to_tsquery(?)) FROM wiki_article AS A, to_tsquery(?) query WHERE query @@ (setweight(to_tsvector(a.title), 'A') || setweight(to_tsvector((SELECT content FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1)), 'D')) ORDER BY rank DESC;"))
	 (result (dbi:execute query searchquery searchquery)))
    (json:encode-json-to-string (mapcar #'(lambda (r) `((title . ,(getf r :|title|))
							(rank  . ,(getf r :|rank|))
							(summary . ,(getf r :|ts_headline|)))) (dbi:fetch-all result)))))

(defget article-list-handler
  (setf (content-type*) "text/json")
  (let* ((articles (mito:select-dao 'wiki-article)))
    (json:encode-json-to-string (mapcar 'wiki-article-title articles))))

(defpost upload-handler
  (let* ((filepath (nth 0 (hunchentoot:post-parameter "file")))
	 ;; (filetype (nth 2 (hunchentoot:post-parameter "file")))
	 (filehash (byte-array-to-hex-string (digest-file :sha512 filepath)))	 ;; TODO whitelist mimetypes TODO verify if mimetype is correct
	 (newpath (merge-pathnames (concatenate 'string "uploads/" filehash) *default-pathname-defaults*)))
	 (print newpath)
	 (copy-file filepath newpath :overwrite t)
	 filehash))

(defpost-noauth login-handler
  (let* ((name (post-parameter "name"))
	 (password (post-parameter "password"))
	 (user (mito:find-dao 'user :name name)))
    (if (and user (password= password (user-hash user)))                        ;; TODO prevent timing attack
	(progn
	  (regenerate-session *SESSION*)
	  (setf (my-session-user *SESSION*) user)
	  (mito:save-dao *SESSION*)
	  nil)
	(progn
	  (setf (return-code*) +http-forbidden+)
	  nil))))

(defpost-noauth logout-handler
  (mito:delete-dao *SESSION*)
  (setf *SESSION* nil))

(defget-noauth killswitch-handler
  (sb-ext:quit))

(defget-noauth-cache file-handler
  (handle-static-file (merge-pathnames (concatenate 'string "uploads/" (subseq (script-name* *REQUEST*) 10)))))

;; this is used to get the most used browsers to decide for future features (e.g. some browsers don't support new features so I won't use them if many use such a browser)
(defun track ()
  (with-open-file (str "track.json"
                     :direction :output
                     :if-exists :append
                     :if-does-not-exist :create)
  (format str "~a~%" (json:encode-json-to-string (acons "user" (my-session-user *session*) (headers-in*))))))

(setq *dispatch-table*
      (nconc
       (list (create-prefix-dispatcher "/api/wiki" 'wiki-page)
	     (create-prefix-dispatcher "/api/killswitch" 'killswitch-handler)
	     (create-prefix-dispatcher "/api/articles" 'article-list-handler)
	     (create-prefix-dispatcher "/api/history" 'wiki-page-history)
	     (create-prefix-dispatcher "/api/revision" 'wiki-revision-handler)
	     (create-prefix-dispatcher "/api/previous-revision" 'previous-revision-handler)
	     (create-prefix-dispatcher "/api/upload" 'upload-handler)
	     (create-prefix-dispatcher "/api/file" 'file-handler)
	     (create-prefix-dispatcher "/api/search" 'search-handler)
	     (create-prefix-dispatcher "/api/login" 'login-handler)
	     (create-prefix-dispatcher "/api/quiz/create" 'create-quiz-handler)
	     (create-prefix-dispatcher "/api/quiz" 'update-quiz-handler)
	     (create-prefix-dispatcher "/api/logout" 'logout-handler))))
