#################################################################################################
### tcrd_tinx.R
###
### Current summary statistics and figures based on MySql db querys.
#################################################################################################
### tinx_articlerank
### tinx_disease
### tinx_importance
### tinx_novelty
### tinx_target
#################################################################################################
library(readr)
library(DBI, quietly=T)
library(RMySQL, quietly=T)
library(data.table, quietly=T)
library(dplyr, quietly=T)
library(plotly, quietly=T)

#
con <- dbConnect(MySQL(), dbname="tcrd", host="juniper.health.unm.edu")
sql <- "SELECT tt.target_id, tt.protein_id, tt.uniprot, tt.sym, tt.tdl, tt.fam, t.name
FROM tinx_target tt
JOIN target t ON tt.target_id = t.id"
tinxt <- dbGetQuery(con, sql)
###
sql <- "SELECT * FROM tinx_disease ORDER BY doid"
tinxd <- dbGetQuery(con, sql)
###
sql <- "SELECT * FROM tinx_novelty"
tinxn <- dbGetQuery(con, sql)
print(sprintf("Novelty score mean: %.2f", mean(tinxn$score)))
print(sprintf("Novelty score median: %.2f", median(tinxn$score)))
print(sprintf("Novelty score max: %.2f", max(tinxn$score)))
for (p in c(1,10,50,90,99))
{
  print(sprintf("Novelty score %2d%%-ile: %6.2f", p, quantile(tinxn$score, p/100)))
}
###
sql <- "SELECT * FROM tinx_importance"
tinxi <- dbGetQuery(con, sql)
print(sprintf("Importance score mean: %.2f", mean(tinxi$score)))
print(sprintf("Importance score median: %.2f", median(tinxi$score)))
print(sprintf("Importance score max: %.2f", max(tinxi$score)))
for (p in c(1,10,50,90,99))
{
  print(sprintf("Importance score %2d%%-ile: %6.2f", p, quantile(tinxi$score, p/100)))
}
###
sql <- "SELECT disease_id, COUNT(protein_id) AS \"protein_count\" 
FROM tinx_importance 
WHERE score IS NOT NULL 
GROUP BY disease_id"
tinx_dtcount <- dbGetQuery(con,sql)
tinx_dtcount <- merge(tinx_dtcount, tinxd[,c("id", "doid", "name")], all.x=T, all.y=F, by.x="disease_id", by.y="id")
write_delim(tinx_dtcount, "data/tinx_dtcount.tsv", "\t")
for (p in c(25,50,75,90,95,99,100))
{
  print(sprintf("Target count per disease %3d%%-ile: %8.1f", p, quantile(tinx_dtcount$protein_count, p/100)))
}
tinx_dtcount <- tinx_dtcount[order(tinx_dtcount$protein_count, decreasing=T), ]
for (i in 1:30)
{
  print(sprintf("%2d. n_target: %5d ; [%d] %s: %s", i, tinx_dtcount$protein_count[i], tinx_dtcount$disease_id[i],
                tinx_dtcount$doid[i], tinx_dtcount$name[i]))
}

###
#COLS: id, importance_id, pmid, rank
#?
#sql <- "SELECT * FROM tinx_articlerank"
#tinxar <- dbGetQuery(con, sql)
#print(sprintf("Article-rank mean: %.2f", mean(tinxar$rank)))
#print(sprintf("Article-rank median: %.2f", median(tinxar$rank)))
#print(sprintf("Article-rank max: %.2f", max(tinxar$rank)))
#for (p in c(1,10,50,90,99))
#{
#  print(sprintf("Article-rank %2d%%-ile: %6d", p, quantile(tinxar$rank, p/100)))
#}


###
doid <- "DOID:14330" #Parkinson's disease
disease_id <- tinxd$id[tinxd$doid == doid]
do_name <- tinxd$name[tinxd$doid == doid]
#did <- 2957 #diabetes mellitus
tinx_this <- tinxi[tinxi$disease_id == disease_id, c("protein_id", "disease_id", "score")]
names(tinx_this)[names(tinx_this) == "score"] <- "importance"
tinx_this <- merge(tinx_this, tinxn[,c("protein_id", "score")], all.x=T, all.y=F, by="protein_id")
names(tinx_this)[names(tinx_this) == "score"] <- "novelty"
tinx_this$disease_id <- NULL #all same
tinx_this <- merge(tinx_this, tinxt, all.x=T, all.y=F, by="protein_id")
tinx_this$fam[is.na(tinx_this$fam)] <- "Other"
tinx_this[["nds"]] <- NA #non-dominated-solution flag
for (i in 1:nrow(tinx_this))
{
  imp <- tinx_this$importance[i]
  nov <- tinx_this$novelty[i]
  for (j in 1:nrow(tinx_this))
  {
    if (i == j)
    {
      next;
    } else if (imp < tinx_this$importance[j] && nov < tinx_this$novelty[j])
    {
      tinx_this$nds[i] <- F
      break
    }
  }
  if (is.na(tinx_this$nds[i])) { tinx_this$nds[i] <- T; }
}
n_nds <- nrow(tinx_this[tinx_this$nds,])
#
###
write_delim(tinx_this, sprintf("data/tinx_%s.tsv", doid), "\t")
#############################################################################
dbDisconnect(con)
#
###
tinx_this[["tdl_color"]] <- "#CCCCCC" #unmapped
tinx_this$tdl_color[tinx_this$tdl == "Tdark"] <- "gray"
tinx_this$tdl_color[tinx_this$tdl == "Tbio"] <- "red"
tinx_this$tdl_color[tinx_this$tdl == "Tchem"] <- "green"
tinx_this$tdl_color[tinx_this$tdl == "Tclin"] <- "blue"
# Plot
p1 <- plot_ly(type='scatter', mode='markers') %>%
  layout(xaxis=list(type="log", title="Novelty"), 
         yaxis=list(type="log", title="Importance"), 
         title=sprintf("<br>(TIN-X: %s (%s)", do_name, doid),
         margin=list(t=100,r=50,b=60,l=60),
         legend=list(x=.95, y=.9), showlegend=T,
         font=list(family="monospace", size=18))
#
add_annotations(p1, text=paste0("(N_gene = ", nrow(tinx_this), ")"), showarrow=F, x=0.1, y=1.0, xref ="paper", yref="paper")
#
for (tdl in unique(tinx_this$tdl)) {
  message(sprintf("DEBUG: add_markers (%s) %d", tdl, nrow(tinx_this[tinx_this$tdl==tdl,])))
  add_markers(p1, name=tdl,
	x=tinx_this$novelty[tinx_this$tdl==tdl],
	y=tinx_this$importance[tinx_this$tdl==tdl],
	marker=list(symbol="circle", color=tinx_this$tdl_color[tinx_this$tdl==tdl]),
	text=sprintf("%s (%s)", tinx_this$sym[tinx_this$tdl==tdl], tinx_this$name[tinx_this$tdl==tdl])
	)
}
if (sum(is.na(tinx_this$tdl))>0) {
  add_markers(p1, name="NA",
	x=tinx_this$novelty[is.na(tinx_this$tdl)],
	y=tinx_this$importance[is.na(tinx_this$tdl)],
	marker=list(symbol="circle", color=tinx_this$tdl_color[is.na(tinx_this$tdl)]),
    text=sprintf("%s (%s)", tinx_this$sym[is.na(tinx_this$tdl)], tinx_this$name[is.na(tinx_this$tdl)])
  )
}
#
p1
#

#
