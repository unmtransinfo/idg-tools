SELECT
	t2tc.target_id,
	p.id,
	p.uniprot,
	p.geneid,
	p.sym,
	p.family
FROM
	t2tc,
	protein p
WHERE
	t2tc.protein_id = p.id
	AND p.uniprot = "P30450"
	;
-- AND p.uniprot = "Q9UP38"
--
SELECT
	p.id,
	p.uniprot,
	p.geneid,
	p.sym,
	p.family
FROM
	protein p
WHERE
	p.uniprot = "P30450"
	;
--
