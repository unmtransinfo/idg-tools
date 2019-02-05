SELECT
	p.sym,
	p.uniprot,
	cdf.attr_cdf,
	SUBSTR(gat.name,1,40) "dataset",
	gat.resource_group
FROM
	protein p,
	hgram_cdf cdf,
	gene_attribute_type gat
WHERE
	p.id = cdf.protein_id
	AND cdf.type = gat.name
	AND p.uniprot = 'Q9Y5P1'
ORDER BY
	gat.resource_group,
	gat.name
	;
--
