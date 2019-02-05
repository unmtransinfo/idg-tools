--
SELECT COUNT(*) AS "harmo_dataset_count"
	FROM gene_attribute_type ;
SELECT COUNT(*) AS "harmo_attribute_count"
	FROM gene_attribute ;
SELECT COUNT(*) AS "harmo_cdf_count"
	FROM hgram_cdf ;
--
SELECT
	id,
	name,
	resource_group,
	attribute_group,
	attribute_type
FROM 
	gene_attribute_type
ORDER BY
	resource_group,
	attribute_group,
	name
	;
--
SELECT
	COUNT(ga.id),
	gat.resource_group
FROM
	gene_attribute ga
JOIN
	gene_attribute_type gat ON gat.id = ga.gat_id
GROUP BY
	gat.resource_group
ORDER BY
	gat.resource_group
	;
--
SELECT
	COUNT(DISTINCT ga.protein_id) "geneset_size",
	gat.name
FROM
	gene_attribute ga
JOIN
	gene_attribute_type gat ON gat.id = ga.gat_id
GROUP BY
	gat.name
ORDER BY
	gat.name
	;
--
