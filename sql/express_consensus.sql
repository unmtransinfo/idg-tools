--
SELECT
	e.protein_id,
	t.name,
	e.tissue,
	COUNT(DISTINCT e.etype) count_distinct_etype,
	COUNT(e.qual_value) count_qual_value
FROM
	expression e
JOIN
	t2tc ON t2tc.protein_id = e.protein_id
JOIN
	target t ON t.id = t2tc.target_id
WHERE
	qual_value IS NOT NULL
GROUP BY
	e.protein_id,
	e.tissue
ORDER BY
	e.protein_id,
	e.tissue,
	count_distinct_etype DESC,
	count_qual_value DESC
	;
--
