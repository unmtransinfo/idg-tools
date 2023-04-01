SELECT DISTINCT
	protein.stringid AS "ensemblProteinId",
	xref.value AS "ensemblGeneId"
FROM
	protein
JOIN
	xref ON xref.protein_id = protein.id
WHERE
	xref.xtype = 'Ensembl' AND xref.value REGEXP '^ENSG'
        ;
