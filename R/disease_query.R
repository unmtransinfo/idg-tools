#!/usr/bin/env Rscript
###
library(readr)
library(data.table, quietly = T)
library(RMySQL, quietly = T)
#library(plotly, quietly = T)

args <- commandArgs(trailingOnly=TRUE)
if (length(args)>0)
{
  (qry <- args[1])
} else {
  qry <- "%diabetes%"
}

writeLines(sprintf("QUERY: WHERE disease.name LIKE '%s'", qry))

dbcon <- dbConnect(MySQL(), host="juniper.health.unm.edu", dbname="tcrd")
sql <- sprintf("SELECT
	d.did, d.name, d.dtype, d.zscore, d.evidence, d.conf,
	d.reference, d.drug_name, d.log2foldchange, d.pvalue, d.score, d.source,
	d.O2S, d.S2O,
	t.id, t.name, t.fam, t.tdl,
	p.uniprot, p.geneid, p.dtoid, p.stringid
FROM
	target t, protein p, t2tc, disease d
WHERE
	d.target_id = t.id AND t2tc.target_id = t.id AND t2tc.protein_id = p.id
	AND d.name LIKE '%s'", qry)
#
tcrd <- dbGetQuery(dbcon,sql)
dbDisconnect(dbcon)
rm(dbcon)
#
setDT(tcrd)
setorder(tcrd, -zscore, -conf)

#writeLines(sprintf("Evidence source: %s [N = %d]", names(table(tcrd$dtype)), table(tcrd$dtype)))
writeLines(sprintf("Evidence sources and disease-gene association counts:"))
for (src in unique(tcrd$dtype)) {
  writeLines(sprintf("%44s: associations: %4d; genes: %4d", src, sum(tcrd$dtype==src), length(unique(tcrd$geneid[tcrd$dtype==src]))))
}
writeLines(sprintf("Total gene associations: %d; unique genes: %d", nrow(tcrd), length(unique(tcrd$geneid))))
#
ofile <- "data/disease_query_out.tsv"
writeLines(sprintf("Output file: %s", ofile))
write_delim(tcrd, ofile, "\t")
#
