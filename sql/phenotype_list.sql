SELECT
        p.ptype,
        CONCAT(IF(INSTR(IFNULL(p.trait, ""), ';')>0, SUBSTR(IFNULL(p.trait, ""), 1, INSTR(IFNULL(p.trait, ""), ';')-1), IFNULL(p.trait, "")),IFNULL(p.term_id, "")) p_identifier,
        p.term_name,
        p.term_description,
        pt.ontology ptype_ontology,
        pt.description ptype_description,
        COUNT(p.protein_id) n_target_associations
FROM
        phenotype p
        JOIN phenotype_type pt ON pt.name = p.ptype
GROUP BY
        p.ptype,
        p_identifier,
        p.term_name,
        p.term_description,
        pt.ontology,
        pt.description
;
