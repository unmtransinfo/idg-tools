-- Top level Panther classes:
SELECT
	pc.name,
	COUNT(DISTINCT p2pc.protein_id) AS "protein_count"
FROM
	p2pc,
	panther_class pc
WHERE
	p2pc.panther_class_id = pc.id
	AND pc.parent_pcids = 'PC00000'
GROUP BY
	pc.name
ORDER BY
	protein_count DESC
	;
--
--	CONCAT('PC',REPEAT('0',5-LENGTH(CAST(p2pc.panther_class_id AS CHAR))),CAST(p2pc.panther_class_id AS CHAR)) = pc.pcid
