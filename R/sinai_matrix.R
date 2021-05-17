#################################################################################################
### sinai_matrix.R
###
### gene-gene association matrix, heatmap, NR human genes only, 'TF ChEA' dataset.
#################################################################################################
library(DBI)
library(RMySQL)

library(gplots)
library(RColorBrewer)


args <- commandArgs(trailingOnly=TRUE)
fname_base <- sprintf("sinai_chea_nr")
t0 <- proc.time()

###
if (!interactive())
{
  pdf(file=paste(c("figures/",fname_base,".pdf"),collapse=""), paper="USr")
}

###
if (!Sys.info()[["nodename"]] == "lengua") #Prefer to test domainname=="health.unm.edu"... How?
{
  print("TCRD/MySql access status unknown; quitting.")
  quit()
}

#Data via MySql, dataframe via dbGetQuery():
con <- dbConnect(MySQL(), dbname="tcrd", host="habanero.health.unm.edu")
#summary(con,verbose=FALSE)
sql <- sprintf(
"SELECT
  p1.id AS \"pid1\",
  p1.sym AS \"sym1\",
  p2.id AS \"pid2\",
  p2.sym AS \"sym2\",
  ga.name AS \"attr\",
  ga.value AS \"value\"
FROM
  protein p1,
  protein p2,
  t2tc tc1,
  target t1,
  t2tc tc2,
  target t2,
  gene_attribute ga
WHERE
  p1.id = ga.protein_id
  AND p1.id = tc1.protein_id
  AND t1.id = tc1.target_id
  AND t1.idgfam = 'NR'
  AND p2.id = tc2.protein_id
  AND t2.id = tc2.target_id
  AND t2.idgfam = 'NR'
  AND ga.type = 'TF ChEA'
  AND ga.name LIKE '%%HUMAN%%'
  AND ga.name LIKE CONCAT(p2.sym, '-%%')")
ggdata <- dbGetQuery(con, sql)
###

ggdata$pid1 <- as.factor(ggdata$pid1)
ggdata$pid2 <- as.factor(ggdata$pid2)
ggdata$value <- as.numeric(ggdata$value)

n_gene <- length(levels(ggdata$pid1))
print(sprintf("Ngenes: %d",n_gene))

pids <- as.vector(levels(ggdata$pid1))

syms <- c()
for (pid in pids)
{
  syms <- c(syms,ggdata[ggdata$pid1 == pid,]$sym1[[1]])
}

n_nonzero <- nrow(ggdata[ggdata$value>0,])
print(sprintf("Nvalues: %d ; nonzero: %d (%.1f%%)",nrow(ggdata),n_nonzero,100*n_nonzero/nrow(ggdata)))

### Create n_gene x n_gene square matrix with values.
m <- matrix(data = NA, nrow = n_gene, ncol = n_gene)
dim(m) <- c(n_gene,n_gene)
rownames(m) <- levels(ggdata$pid1)
colnames(m) <- levels(ggdata$pid1)

for (i in 1:nrow(ggdata))
{
  pid1 <- ggdata[i,][["pid1"]]
  pid2 <- ggdata[i,][["pid2"]]
  idx1 <- which(pids == pid1)
  idx2 <- which(pids == pid2)
  m[idx1,idx2] <- ggdata[i,][["value"]]
  m[idx2,idx1] <- m[idx1,idx2]
}

### Heatmap

heatmap.2(m,
          labRow = syms, cexRow = 0.7,
          labCol = syms, cexCol = 0.9,
          main = "ChEA gene-gene interactions (NR)",
          dendrogram="none",
          trace="none",
          density.info="none",
          col=colorRampPalette(c("gray", "red"))(n=10))
