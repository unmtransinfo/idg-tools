-- 
-- act_type, act_value, action_type, cmpd_chemblid, drug, has_moa, id, nlm_drug_info, reference, smiles, source, target_id
-- 
SELECT
	t.id,
	p.sym,
	t.fam,
	t.tdl,
	da.drug AS "name",
	da.has_moa,
	da.action_type,
	da.act_type,
	da.act_value,
	da.source,
	da.cmpd_chemblid
FROM
	target t
JOIN
	drug_activity da ON da.target_id = t.id
JOIN
	t2tc ON t.id = t2tc.target_id
JOIN
	protein p ON p.id = t2tc.protein_id
WHERE
	da.act_value IS NOT NULL
ORDER BY
	t.id,
	da.drug
	;
--
