--
-- gene-gene associations via attributes.
-- NR idgfam only (47 genes).
-- Number of values: 816?
--
SELECT
	p1.id AS "protein_id1",
	p1.sym AS "protein_sym1",
	p2.id AS "protein_id2",
	p2.sym AS "protein_sym2",
	ga.name AS "attr_name1",
	ga.value AS "attr_value1"
FROM
	protein p1,
	protein p2,
	t2tc tc1,
	target t1,
	t2tc tc2,
	target t2,
	gene_attribute ga
WHERE
	p1.id = ga.protein_id
	AND p1.id = tc1.protein_id
	AND t1.id = tc1.target_id
	AND t1.idgfam = 'NR'
	AND p2.id = tc2.protein_id
	AND t2.id = tc2.target_id
	AND t2.idgfam = 'NR'
	AND ga.type = 'TF ChEA'
	AND ga.name LIKE '%HUMAN%'
	AND ga.name LIKE CONCAT(p2.sym, '-%')
ORDER BY
	p1.id, p2.id
	;
--
