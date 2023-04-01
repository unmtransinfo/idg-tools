--
--
-- mu = 23.20, sigma = 14.43
--
SELECT
	p.sym AS "gene_sym",
	SUM(CAST(ga.value AS DECIMAL)) AS "attr_count",
	(
	  1.0 / (1.0 + exp(-1.702*((SUM(CAST(ga.value AS DECIMAL))-23.20)/14.43)))
	) AS "attr_cdf"
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
