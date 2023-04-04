--SELECT
--	ga.type,
--	COUNT(ga.id)
--FROM
--	gene_attribute ga
--GROUP BY
--	ga.type
--	;
--
--SELECT
--	ga.type,
--	COUNT(ga.id) AS "count_human"
--FROM
--	gene_attribute ga
--WHERE
--	ga.name LIKE '%HUMAN%'
--GROUP BY
--	ga.type
--	;
--
--
-- ERROR 3 (HY000) at line 10: Error writing file '/tmp/MYHX1BKN' (Errcode: 28)
--SELECT
--	type,
--	COUNT(DISTINCT protein_id)
--FROM
--	gene_attribute
--GROUP BY
--	type
--	;
--
SELECT
	ga.value,
	COUNT(ga.id)
FROM
	gene_attribute ga
WHERE
--	ga.type = 'TF ChEA'
	ga.name LIKE '%HUMAN%'
GROUP BY
	ga.value
	;
--
--
SELECT
	p.id AS "protein_id",
	p.sym AS "protein_sym",
	ga.name AS "attr_name",
	ga.value AS "attr_value"
FROM
	protein p,
	gene_attribute ga
WHERE
	p.id = ga.protein_id
--	AND ga.type = 'TF ChEA'
	AND ga.name LIKE '%HUMAN%'
LIMIT 50
	;
--
