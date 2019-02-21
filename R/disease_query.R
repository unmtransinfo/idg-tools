#!/usr/bin/env Rscript
###
library(readr)
library(data.table, quietly = T)
library(RMySQL, quietly = T)

DBNAME <- "tcrd"
DBHOST <- "juniper.health.unm.edu"

args <- commandArgs(trailingOnly=TRUE)
if (interactive()) {
  qry <- "^Diabetes.*Type 2|^Type 2.*Diabetes"
} else if (length(args)>0) {
  (qry <- args[1])
} else {
  message("ERROR: syntax: PROG DISEASE_QUERY_REGEX")
  quit()
}

print(Sys.Date())
writeLines(sprintf("DBHOST: %s; DBNAME: %s", DBHOST, DBNAME))
writeLines(sprintf("QUERY: WHERE disease.name REGEXP '%s'", qry))

dbcon <- dbConnect(MySQL(), host=DBHOST, dbname=DBNAME)
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
	AND d.name REGEXP '%s'", qry)
#
tcrd <- dbGetQuery(dbcon,sql)
dbDisconnect(dbcon)
rm(dbcon)
#
setDT(tcrd)
#
dcounts <- tcrd[, .(N = .N), by = .(name = name)]
setorder(dcounts, -N)
writeLines(sprintf("Total unique disease terms: %d", nrow(dcounts)))
writeLines(sprintf("%d. %d (%.1f%%) %s", 1:nrow(dcounts), dcounts$N, 100*dcounts$N/nrow(tcrd), dcounts$name))
#
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
