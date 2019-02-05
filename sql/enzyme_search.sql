SELECT
	protein.id,
	protein.uniprot,
	protein.geneid,
	protein.sym,
	target.tdl,
	protein.family
FROM
	protein,
	t2tc,
	target
WHERE
	(family LIKE '%ase %'
	OR family LIKE '%ase) %'
	OR family LIKE '%ase-like %'
	OR family LIKE '%ases %')
	AND protein.id = t2tc.protein_id
	AND target.id = t2tc.target_id
ORDER BY protein.id
	;
--
