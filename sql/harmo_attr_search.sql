SELECT DISTINCT
	ga.name,
	SUBSTR(gat.name,1,40) "dataset"
FROM
	gene_attribute ga,
	gene_attribute_type gat
WHERE
	ga.gat_id = gat.id
	AND gat.resource_group = 'transcriptomics'
	AND UPPER(ga.name) LIKE '%BRAIN%'
ORDER BY
	gat.name,
	ga.name
	;
--
--	AND gat.name NOT LIKE 'Allen Brain Atlas%'
