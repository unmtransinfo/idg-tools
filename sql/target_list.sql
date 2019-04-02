SELECT
	target.id,
	target.name,
	target.fam,
	target.tdl,
	target.idg2,
	protein.id,
	protein.sym,
	protein.family,
	protein.geneid,
	protein.uniprot,
	protein.up_version,
	protein.name,
	protein.stringid,
	protein.chr,
	protein.description,
	protein.dtoid
FROM
	target
JOIN
	t2tc ON t2tc.target_id = target.id
JOIN
	protein ON protein.id = t2tc.protein_id
	;
--
