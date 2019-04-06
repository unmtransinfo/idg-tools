library(readr)
library(data.table)

tcrd_geno2pheno_impc <- read_delim("/home/data/TCRD/data/tcrd_geno2pheno_impc.tsv", "\t")
setDT(tcrd_geno2pheno_impc)

mpml_mouse_phen <- read_delim("/home/data/metap/data/mouse.phen.tsv.gz", "\t")
setDT(mpml_mouse_phen)

n_mpml <- uniqueN(mpml_mouse_phen$human_protein_id)
n_tcrd <- uniqueN(tcrd_geno2pheno_impc$protein_id)

writeLines(sprintf("Human genes in MPML IMPC g2p: %d", n_mpml))
writeLines(sprintf("Human genes in TCRD IMPC g2p: %d", n_tcrd))
writeLines(sprintf("Delta: %d (%.1f%%)", n_tcrd-n_mpml, 100*(n_tcrd-n_mpml)/n_mpml))

# IMPC release 9.2 (Jan 29, 2019)
# ftp://ftp.ebi.ac.uk/pub/databases/impc/release-9.2/csv/

impc_g2p <- read_delim("/home/data/IMPC/data/release-9.2/IMPC_genotype_phenotype.csv", ",")

ortholog <- read_delim("/home/data/TCRD/data/tcrd_ortholog_mouse.tsv", "\t",
                       col_types="nccccccc")
setDT(ortholog)
ortholog[, c("id",  "taxid", "species", "mgi_url"):=NULL]

impc_g2p <- merge(impc_g2p, ortholog, by.x="marker_accession_id", by.y="mgi_id", all.x=T, all.y=F)
