--
SELECT DISTINCT
	e.tissue,
	e.etype,
	e.protein_id,
	e.number_value,
	e.zscore,
	e.conf,
	e.oid,
	p.sym AS "psymb",
	p.name AS "pname",
	t.id AS "tid",
	t.idgfam,
	t.tdl
FROM
	expression e
JOIN
	protein p ON e.protein_id = p.id
JOIN
	t2tc ON p.id = t2tc.protein_id
JOIN
	target t ON t2tc.target_id = t.id
WHERE
	e.etype IN ( 'HPM Protein', 'GTEx' )
	AND t.idgfam IS NOT NULL
ORDER BY
	e.tissue, e.zscore, t.idgfam
	;
--
