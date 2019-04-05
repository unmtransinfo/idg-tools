-- 
-- IMPC: Export phenotype-target associations.
--
SELECT
	pt.protein_id,
	p.sym,
	p.uniprot,
	p.geneid,
	t.name,
	t.tdl,
	pt.id AS "tcrd_phenotype_id",
	pt.term_id AS "mp_term_id",
	pt.term_name AS "mp_term_name",
	pt.top_level_term_id AS "top_level_mp_term_id",
	pt.top_level_term_name AS "top_level_mp_term_name",
	pt.sex AS "mp_sex",
	pt.p_value,
	pt.percentage_change,
	pt.effect_size,
	pt.statistical_method
FROM
	phenotype pt
JOIN
	protein p ON p.id = pt.protein_id
JOIN
	t2tc ON t2tc.protein_id = pt.protein_id
JOIN
	target t ON t.id = t2tc.target_id
WHERE
	pt.ptype = 'IMPC'
ORDER BY
	p.sym
	;
--
