--
--
-- mu = 13.05, sigma = 24.56
--
SELECT
	p.sym AS "gene_sym",
	COUNT(t2p.id) AS "attr_count",
	(
	  1.0 / (1.0 + exp(-1.702*((COUNT(t2p.id)-13.05)/24.56)))
	) AS "attr_cdf"
FROM
	protein p
JOIN
	t2tc ON p.id = t2tc.protein_id
JOIN
	target t ON t.id = t2tc.target_id
JOIN
	target2pathway t2p ON t.id = t2p.target_id
GROUP BY
	p.sym
ORDER BY
	p.sym
	;
--
