--- 
SELECT
	COUNT(DISTINCT pt.term_id) AS "pheno_id_count",
	COUNT(DISTINCT pt.trait) AS "pheno_trait_count",
	COUNT(DISTINCT pt.protein_id) AS "protein_id_count",
	pt.ptype
FROM
	phenotype pt
GROUP BY
	pt.ptype
	;
--
