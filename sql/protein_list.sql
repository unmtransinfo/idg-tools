SELECT
	protein.id,
	protein.uniprot,
	protein.geneid,
	protein.sym,
	protein.chr,
	protein.stringid,
	target.name,
	target.tdl,
	target.fam
FROM
	protein
JOIN
	t2tc ON protein.id = t2tc.protein_id
JOIN
	target ON t2tc.target_id = target.id
WHERE
	protein.sym IS NOT NULL
ORDER BY
	protein.sym
	;
--
