SELECT COUNT(DISTINCT id) AS "generif_count" FROM generif ;
--
SELECT COUNT(DISTINCT id) AS "generif_count_huge" FROM generif WHERE text LIKE '%(HuGE Navigator)%' ;
--
SELECT COUNT(DISTINCT protein_id) AS "generif_protein_count" FROM generif ;
--
SELECT 
	COUNT(DISTINCT pubmed_ids) AS "generif_pmid_count"
FROM
	generif
WHERE
	pubmed_ids NOT LIKE '%|%'
	;
--
SELECT
	g.protein_id,
	COUNT(DISTINCT g.id) AS "rif_count",
	LENGTH(GROUP_CONCAT(g.text)) AS "rif_len"
FROM
	generif g,
	protein p
WHERE
	p.id = g.protein_id
GROUP BY
	g.protein_id
ORDER BY
	rif_count DESC,
	rif_len DESC
LIMIT 100
	;
--
SELECT SUM(LENGTH(text))/COUNT(text) FROM generif ;
--
