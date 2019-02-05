SELECT
	SUBSTR(gat.name,1,40) "dataset",
	gat.resource_group,
	p.sym,
	p.uniprot,
	cdf.attr_cdf,
	t.idgfam,
	t.tdl
FROM
	protein p,
	target t,
	t2tc,
	hgram_cdf cdf,
	gene_attribute_type gat
WHERE
	p.id = cdf.protein_id
	AND cdf.type = gat.name
	AND gat.name = 'Reactome Pathways'
	AND t2tc.target_id = t.id
	AND t2tc.protein_id = p.id
	AND t.idgfam IS NOT NULL
ORDER BY
	t.idgfam,
	t.tdl,
	p.sym
	;
--
