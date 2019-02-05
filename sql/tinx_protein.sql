SELECT
	p.id,
	p.sym,
	i.score "importance",
	n.score "novelty",
	d.doid,
	d.name "disease",
	d.num_important_targets,
	d.novelty_score
FROM
	protein p,
	tinx_importance i,
	tinx_novelty n,
	tinx_disease d
WHERE
	p.id = i.protein_id
	AND p.uniprot IN ( 'Q9Y5P1','Q6UXY8' )
	AND i.protein_id = n.protein_id
	AND d.id = i.disease_id
ORDER BY
	p.id
;
