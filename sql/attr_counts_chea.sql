--
--
SELECT
	p.sym AS "gene_sym",
	SUM(CAST(ga.value AS DECIMAL)) AS "attr_count"
FROM
	protein p
LEFT JOIN
	gene_attribute ga ON p.id = ga.protein_id
--WHERE
--	ga.type = 'TF ChEA'
GROUP BY
	p.sym
ORDER BY
	p.sym
	;
--
