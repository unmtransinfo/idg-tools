-- 
SELECT
	dataset.id,
	dataset.name,
	CASE
		WHEN LENGTH(dataset.source)>120 THEN CONCAT(RPAD(SUBSTRING(dataset.source,1,116),116,' '),'...')
		ELSE dataset.source
	END AS "source"
FROM
	dataset
ORDER BY
	dataset.name
	;
--
--	dataset.app
--	TRIM(dataset.source),
--	CONCAT(RPAD(SUBSTRING(dataset.source,1,80),80,' '),'...') AS "source",
