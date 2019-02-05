--
SELECT
	COUNT(DISTINCT protein.id),
	target.tdl
FROM
	protein,
	t2tc,
	target
WHERE
	(family LIKE '%ase %' OR family LIKE '%ase) %' OR family LIKE '%ase-like %' OR family LIKE '%ases %')
	AND protein.id = t2tc.protein_id
	AND target.id = t2tc.target_id
GROUP BY target.tdl
ORDER BY target.tdl
	;
--
SELECT
	COUNT(DISTINCT protein.id) AS "total"
FROM
	protein
WHERE
	(family LIKE '%ase %' OR family LIKE '%ase) %' OR family LIKE '%ase-like %' OR family LIKE '%ases %')
	;
--
