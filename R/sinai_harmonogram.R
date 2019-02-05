gene_attributes <- read.delim("drugbank/gene_attribute_edges.txt")
names(gene_attributes) <- c("GeneSym","Uniprot","GeneID","Drugname","DrugBankID","target_id","weight")
gene_attributes <- gene_attributes[-1,]

gene_attributes$GeneSym <- as.factor(gene_attributes$GeneSym)

gene_attributes$Drugname <- as.factor(gene_attributes$Drugname)

n_gene <- length(levels(gene_attributes$GeneSym))
print(sprintf("n_gene = %d",n_gene))

n_drug <- length(levels(gene_attributes$Drugname))
print(sprintf("n_drug = %d",n_drug))

counts <- data.frame(GeneSym = levels(gene_attributes$GeneSym))

counts$Count <- rep(0,length(counts$GeneSym))

for (i in 1:nrow(counts))
{
  genesym <- counts[i,]$GeneSym
  counts[i,]$Count <- nrow(gene_attributes[gene_attributes$GeneSym == genesym,])
}

#Empirical Cumulative Distribution Function
cdf <- ecdf(counts$Count)
plot(cdf, xlab = "Gene association count", ylab = "P", verticals = TRUE, col.points = "blue",
     col.hor = "red", col.vert = "bisque", main = NA)
title(main="CDF for gene association count")
