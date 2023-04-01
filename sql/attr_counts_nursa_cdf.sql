--
--
-- mu = 29.70, sigma = 111.81
--
SELECT
	p.sym AS "gene_sym",
	SUM(CAST(ga.value AS DECIMAL)) AS "attr_count",
	(
	  1.0 / (1.0 + exp(-1.702*((SUM(CAST(ga.value AS DECIMAL))-29.70)/111.81)))
	) AS "attr_cdf"
FROM
	protein p
LEFT JOIN
	gene_attribute ga ON p.id = ga.protein_id
--WHERE
--	ga.type = 'IP NURSA'
GROUP BY
	p.sym
ORDER BY
	p.sym
	;
--
