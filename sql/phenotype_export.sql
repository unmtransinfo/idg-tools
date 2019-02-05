--- 
--- Export distinct phenotypes only, not target associations.
--- 
--- GWAS Catalog:
SELECT DISTINCT
	pt.ptype AS "phenotype_type",
	pt.trait AS "phenotype_trait"
FROM
	phenotype pt
WHERE
	pt.trait IS NOT NULL
ORDER BY
	pt.trait
	;
--
--- IMPC:
SELECT DISTINCT
	pt.ptype AS "phenotype_type",
	pt.term_id AS "phenotype_id",
	pt.term_name AS "phenotype_term_name"
FROM
	phenotype pt
WHERE
	pt.term_id IS NOT NULL
ORDER BY
	pt.term_name
	;
--
