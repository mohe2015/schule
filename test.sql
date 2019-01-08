SELECT id FROM wiki_article_revision WHERE to_tsvector('german', content) @@ to_tsquery('german', 'Elefant');

SELECT to_tsvector('german', content) FROM wiki_article_revision;

SELECT a.title, r.content FROM wiki_article AS a JOIN wiki_article_revision AS r ON r.id = (SELECT id FROM wiki_article_revision WHERE article_id = a.id ORDER BY id DESC LIMIT 1);
