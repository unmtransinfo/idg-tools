-- 
SELECT
	t.id target_id,
	p.id protein_id,
	p.sym protein_symbol,
	t.name protein_name,
	t.fam,
	t.tdl,
	p.uniprot,
	p.stringid ensemblid,
	ca.cmpd_name_in_src compound_name,
	ca.catype activity_source,
	ca.act_type,
	ca.act_value,
	ca.smiles,
	ca.cmpd_pubchem_cid pubchem_cid
FROM
	target t
JOIN
	cmpd_activity ca ON ca.target_id = t.id
JOIN
	t2tc ON t.id = t2tc.target_id
JOIN
	protein p ON p.id = t2tc.protein_id
WHERE
	ca.act_value IS NOT NULL
ORDER BY
	t.id,
	ca.cmpd_pubchem_cid
	;
--
