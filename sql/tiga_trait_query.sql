SELECT
	trait,
	efoid,
	protein_id,
	ensg,
	pvalue_mlog_median,
	or_median,
	n_beta,
	rcras,
	meanRankScore
FROM
	tiga 
WHERE
	efoid = 'EFO_0000249'
ORDER BY meanRankScore DESC
	;
