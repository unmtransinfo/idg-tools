SELECT
	p.id,
	p.sym,
	i.score "importance",
	n.score "novelty",
	d.doid,
	d.name "disease"
--	d.num_important_targets,
--	d.novelty_score
FROM
	protein p,
	tinx_importance i,
	tinx_novelty n,
	tinx_disease d
WHERE
	p.id = i.protein_id
	AND i.protein_id = n.protein_id
	AND d.doid = i.doid
ORDER BY
	p.id
;
