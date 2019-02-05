--- 
--- Consider phenotypes associated with metabolic disorders, i.e. diabetes,
--- kidney/liver function.
--- 
SELECT
	pt.term_id AS "phenotype_id",
	pt.term_name AS "phenotype_term_name",
	pt.ptype AS "phenotype_type",
	pt.trait AS "phenotype_trait",
	p.id AS "protein_id",
	p.name AS "protein_name",
	p.description AS "protein_description",
	t.idgfam,
	t.tdl
FROM
	phenotype pt,
	target t,
	t2tc,
	protein p
WHERE
	pt.protein_id = p.id
	AND t2tc.protein_id = p.id
	AND t2tc.target_id = t.id
	AND
	  ((UPPER(pt.term_name) LIKE '%BLOOD UREA NITROGEN%')
	   OR (UPPER(pt.term_name) LIKE '%GLUCOSE%'))
ORDER BY
	p.id, pt.id
	;
--	AND p.sym = 'GPER1'
