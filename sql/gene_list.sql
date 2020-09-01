SELECT DISTINCT
	target.id AS "tcrdTargetId",
	target.name AS "tcrdTargetName",
	target.fam AS "tcrdTargetFamily",
	target.tdl AS "TDL",
	target.idg AS "idgList",
	protein.sym AS "geneSymbol",
	protein.geneid AS "ncbiGeneId",
	xref.value AS "ensemblGeneId"
FROM
	target
JOIN
	t2tc ON t2tc.target_id = target.id
JOIN
	protein ON protein.id = t2tc.protein_id
JOIN
	xref ON xref.protein_id = protein.id
WHERE
	xref.xtype = 'Ensembl' AND xref.value REGEXP '^ENSG'
ORDER BY
	protein.sym
        ;
