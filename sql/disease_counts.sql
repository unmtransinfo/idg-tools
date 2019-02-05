-- 
SELECT COUNT(DISTINCT d.name) AS "disease_count" FROM disease d ;
-- 
SELECT
	d.name AS "disease",
	t.fam,
	count(*) as count_disease
FROM
	disease d
JOIN
	target t ON d.target_id = t.id
WHERE
	t.fam IS NOT NULL
GROUP BY d.name, t.fam
ORDER BY count_disease DESC
	;
-- LIMIT 100
