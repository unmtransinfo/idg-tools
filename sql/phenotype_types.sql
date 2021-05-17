SELECT
	p.ptype,
        pt.ontology ptype_ontology,
        pt.description ptype_description,
        COUNT(DISTINCT CONCAT(IF(INSTR(IFNULL(p.trait, ""), ';')>0, SUBSTR(IFNULL(p.trait, ""), 1, INSTR(IFNULL(p.trait, ""), ';')-1), IFNULL(p.trait, "")),IFNULL(p.term_id, ""))) phenotype_count,
	COUNT(DISTINCT p.protein_id) protein_count
FROM
	phenotype p
	JOIN phenotype_type pt ON pt.name = p.ptype
GROUP BY
	p.ptype,
        pt.ontology,
        pt.description
	;
--
