--- 
SELECT COUNT(DISTINCT og.id) AS "ortholog_count_total" FROM ortholog og ;
--- 
SELECT
	COUNT(DISTINCT og.id) AS "ortholog_count",
	og.sources AS "sources"
FROM
	ortholog og
GROUP BY
	og.sources
ORDER BY
	og.sources
	;
--
SELECT
	COUNT(DISTINCT og.id) AS "ortholog_count",
	og.species AS "species"
FROM
	ortholog og
GROUP BY
	og.species
ORDER BY
	og.species
	;
--
