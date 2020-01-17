SELECT DISTINCT 
	clinvar.protein_id,
	protein.sym,
	clinvar_phenotype.id AS clinvar_phenotype_id,
	clinvar.clinical_significance,
	clinvar_phenotype.name,
	omim.mim AS mim_id,
	omim.title AS mim_title
FROM 
	clinvar, clinvar_phenotype, clinvar_phenotype_xref, protein, omim
WHERE
	clinvar.clinvar_phenotype_id = clinvar_phenotype.id
	AND clinvar_phenotype.id = clinvar_phenotype_xref.clinvar_phenotype_id  
	AND clinvar_phenotype_xref.source = 'OMIM'
	AND clinvar_phenotype_xref.value = omim.mim
	AND clinvar.protein_id = protein.id
	AND clinvar.clinical_significance NOT IN (
		'Uncertain significance',
		'Uncertain significance, association',
		'Uncertain significance, other',
		'other, risk factor',
		'other')
	;
