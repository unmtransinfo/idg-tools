SELECT
	id,
	protein_id,
	pubmed_ids,
	text,
	years
FROM
	generif
WHERE
	text LIKE '%prostate % cancer%'
	;
--
