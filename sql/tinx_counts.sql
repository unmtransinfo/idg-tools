SELECT
	COUNT(DISTINCT p.id) AS "proteins_with_novelty_count"
FROM
	protein p
JOIN
	tinx_novelty n ON n.protein_id = p.id
WHERE
	n.score IS NOT NULL
	;
--
SELECT
	COUNT(DISTINCT p.id) AS "proteins_with_importance_count"
FROM
	protein p
JOIN
	tinx_importance i ON i.protein_id = p.id
WHERE
	i.score IS NOT NULL
	;
--
SELECT
	COUNT(DISTINCT p.id) AS "tinx_protein_count",
	d.doid,
	d.name
FROM
	protein p
JOIN
	tinx_importance i ON i.protein_id = p.id
JOIN
	tinx_novelty n ON n.protein_id = p.id
JOIN
	tinx_disease d ON d.doid = i.doid
WHERE
	i.score IS NOT NULL
	AND n.score IS NOT NULL
	AND d.doid IN (
		SELECT doid FROM tinx_disease WHERE RAND() < 0.01
	)
GROUP BY
	d.doid,
	d.name
ORDER BY
	CAST(REPLACE(d.doid, 'DOID:', '') AS UNSIGNED)
	;
