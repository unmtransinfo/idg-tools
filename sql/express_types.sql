--
--SELECT
--	name,
--	data_type,
--	description
--FROM
--	expression_type
--ORDER BY
--	name
--	;
--
SELECT
	etype
--	string_value,
--	COUNT(string_value)
FROM
	expression;
--WHERE
--	string_value IS NOT NULL
--GROUP BY
--	etype
--ORDER BY
--	etype
--	string_value
--	;
--
--SELECT
--	etype
--	boolean_value,
--	COUNT(boolean_value)
--FROM
--	expression
--WHERE
--	boolean_value IS NOT NULL
--GROUP BY
--	etype
--ORDER BY
--	etype
--	boolean_value
	;
--
SELECT
	etype,
	COUNT(number_value)
FROM
	expression
WHERE
	number_value IS NOT NULL
GROUP BY
	etype
ORDER BY
	etype
	;
--
SELECT
	etype,
	qual_value,
	COUNT(qual_value)
FROM
	expression
WHERE
	qual_value IS NOT NULL
GROUP BY
	etype
ORDER BY
	etype,
	qual_value
	;
--
SELECT COUNT(DISTINCT tissue) AS "tissue_count" FROM expression ;
SELECT COUNT(*) AS "qual_value_null_count" FROM expression WHERE qual_value IS NULL ;
--
SELECT
	tissue,
	COUNT(DISTINCT etype) count_distinct_etype,
	COUNT(qual_value) count_qual_value
FROM
	expression
WHERE
	qual_value IS NOT NULL
GROUP BY
	tissue
ORDER BY
	count_distinct_etype DESC,
	count_qual_value DESC
	;
--
