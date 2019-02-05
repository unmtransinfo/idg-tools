--- LIKE '%foo%' is case-insensitive by default in MySql.
--	p.name AS "Protein",
SELECT
	d.did,
	d.name AS "Disease",
	d.zscore,
	d.conf,
	p.description AS "Protein",
	t.fam,
	t.tdl
FROM
	target t,
	protein p,
	t2tc,
	disease d
WHERE
	d.target_id = t.id
	AND t2tc.target_id = t.id
	AND t2tc.protein_id = p.id
	AND d.zscore IS NOT NULL
	AND t.fam IS NOT NULL
	AND d.name LIKE '%gout%'
ORDER BY d.name,d.conf DESC
	;
