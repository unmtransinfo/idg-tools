--- 
SELECT COUNT(DISTINCT ogd.id) AS "ortholog_disease_count_total" FROM ortholog_disease ogd ;
SELECT COUNT(DISTINCT ogd.did) AS "disease_count" FROM ortholog_disease ogd ;
SELECT COUNT(DISTINCT ogd.ortholog_id) AS "ortholog_count" FROM ortholog_disease ogd ;
SELECT COUNT(DISTINCT ogd.target_id) AS "target_count" FROM ortholog_disease ogd ;
--- 
SELECT
	COUNT(DISTINCT ogd.id) AS "ortholog_disease_count",
	og.species AS "species"
FROM
	ortholog_disease ogd
JOIN
	ortholog og ON og.id = ogd.ortholog_id
GROUP BY
	og.species
ORDER BY
	og.species
	;
--
