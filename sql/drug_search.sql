--- 
SELECT
	d.id AS "drug_id",
	d.drug AS "drug_name",
	d.action_type,
	d.source,
	p.name AS "protein_name",
	p.description AS "protein_description",
	t.fam,
	t.tdl
FROM
	drug_activity d,
	target t,
	t2tc,
	protein p
WHERE
	d.target_id = t.id
	AND t2tc.target_id = t.id
	AND t2tc.protein_id = p.id
	AND UPPER(p.description) LIKE '%ESTROGEN%'
ORDER BY
	p.name, d.id
	;
--	AND p.sym = 'GPER1'
