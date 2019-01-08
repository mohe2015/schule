SELECT id FROM wiki_article_revision WHERE to_tsvector('german', content) @@ to_tsquery('german', 'Elefant');

SELECT to_tsvector('german', content) FROM wiki_article_revision;

SELECT a.title, r.content FROM wiki_article AS a JOIN wiki_article_revision AS r ON r.id = (SELECT id FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1);


 SELECT a.title, r.content FROM wiki_article AS a JOIN wiki_article_revision AS r ON r.id = (SELECT id FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1) WHERE to_tsvector('german', r.content) @@ to_tsquery('german', 'Elefant');
 
 
 SELECT a.title, r.content FROM wiki_article AS a JOIN wiki_article_revision AS r ON r.id = (SELECT id FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1) WHERE setweight(to_tsvector('german', a.title), 'A') || setweight(to_tsvector('german', r.content), 'D') @@ to_tsquery('german', 'Elefant');

 
 
 

CREATE INDEX test1 ON wiki_article_revision USING GIN ((to_tsvector('german', content)));

CREATE INDEX test2 ON wiki_article_revision USING GIN ((setweight(to_tsvector('german', content), 'D')));

 
 
 CREATE INDEX test3 ON wiki_article_revision USING GIN ((setweight(to_tsvector('german', 'title'), 'A') || setweight(to_tsvector('german', content), 'D')));
 
 
 
 CREATE INDEX test3 ON wiki_article_revision USING GIN ((setweight(to_tsvector('german', (SELECT title FROM wiki_article AS a WHERE a.id = article_id)), 'A') || setweight(to_tsvector('german', content), 'D')));
