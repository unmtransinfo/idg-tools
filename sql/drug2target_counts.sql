--- 
SELECT
	drugdb_activity.drug,
	drugdb_activity.has_moa,
	drugdb_activity.source,
	target.id,
	target.idgfam,
	target.tdl
FROM
	drugdb_activity
LEFT OUTER JOIN
	target ON drugdb_activity.target_id = target.id
WHERE
	target.tdl IN ('Tclin','Tclin+')
ORDER BY
	drugdb_activity.drug
	;
--
