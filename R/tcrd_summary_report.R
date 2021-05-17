#################################################################################################
### tcrd_summary_report.R
###
### Current summary statistics and figures based on MySql db querys.
#################################################################################################
library(DBI)
library(RMySQL)

args <- commandArgs(trailingOnly=TRUE)
fname_base <- sprintf("tcrd_summary")
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
con <- dbConnect(MySQL(), dbname="tcrd", host="juniper.health.unm.edu")
#summary(con,verbose=FALSE)
sql <- sprintf(
"SELECT
	p.id AS \"protein_id\",
	t.id AS \"target_id\",
	t.idgfam,
	t.tdl
FROM
	target t,
	protein p,
	t2tc
WHERE
	t2tc.target_id = t.id
	AND t2tc.protein_id = p.id")
tgtdata <- dbGetQuery(con, sql)
###

#tgtdata$idgfam <- as.factor(tgtdata$idgfam)
#tgtdata$tdl <- as.factor(tgtdata$tdl)

#Exclude non-IDGFAM and oGPCR here:
t_tdl <- table(tgtdata[!is.na(tgtdata$idgfam) & tgtdata$idgfam!='oGPCR',c('tdl')])
t_tdl <- as.table(t_tdl[c(4,1,2,3)]) #fix from alpha order
print(t_tdl)

#Exclude non-IDGFAM:
t_idgfam <- table(tgtdata[!is.na(tgtdata$idgfam),c('idgfam')])
print(t_idgfam)


tdls <- c('Tdark','Tbio','Tchem','Tclin')
tdl_colors <- c("gray17","red","green","blue")

###
###Stacked barplot
par(mfrow = c(1, 1))
par(oma = c(0,0,0,1))

t2 <- table(tgtdata[tgtdata$idgfam!='oGPCR',c('tdl','idgfam')])
t2 <- t2[tdls,]
print(t2)
barplot(t2, legend = rownames(t2), col=tdl_colors)
title(main="TCRD TDLs (IDG-Families only, no oGPCR)")
mtext(text=date(), side=4, outer=T)


### 3D Exploded Pie Chart
library(plotrix)

orig.par <- par(no.readonly = TRUE) # save default
#par(mfrow = c(1, 2))
par(mar = c(3,1,1,1))
par(oma = c(1,1,1,1))

counts <- as.data.frame(t_tdl)[,2]
labs <- as.data.frame(t_tdl)[,1]
labs <- paste(labs, sprintf("\n%d (%d%%)",counts, round(counts/sum(counts)*100))) # annotate labels
pie_colors <- tdl_colors
pie3D(counts,labels=labs,explode=0.1, col=pie_colors, labelcex=0.8)
title(main="TCRD TDLs (IDG-Families only, no oGPCR)")
mtext(text=date(), side=4, outer=T)
#
counts <- as.data.frame(t_idgfam)[,2]
labs <- as.data.frame(t_idgfam)[,1]
labs <- paste(labs, sprintf("\n%d (%d%%)",counts, round(counts/sum(counts)*100))) # annotate labels
pie_colors <- rainbow(n=length(labs), start=0, end = 5/6, alpha = 0.7)
pie3D(counts,labels=labs,explode=0.1, col=pie_colors, labelcex=0.8)
title(main="TCRD IDG-Families")
mtext(text=date(), side=4, outer=T)

### Non-IDGFAM:
par(mfrow = c(1, 1))
t3 <- table(tgtdata[is.na(tgtdata$idgfam),'tdl'])
t3 <- t3[tdls]
labs <- rownames(t3)
labs <- paste(labs, sprintf("\n%d (%d%%)",t3, round(t3/sum(t3)*100))) # annotate labels
pie3D(t3, labels=labs, explode=0.1, col=tdl_colors, labelcex=0.8)
title(main="TCRD TDLs for Non-IDG-FAM")
mtext(text=date(), side=4, outer=T)

###
### Panther classes (top-level)
sql <- sprintf(
"SELECT
	pc.name AS \"panther_class\",
	COUNT(DISTINCT p2pc.protein_id) AS \"protein_count\"
FROM
	p2pc,panther_class pc
WHERE
	CONCAT('PC',REPEAT('0',5-LENGTH(CAST(p2pc.panther_class_id AS CHAR))),CAST(p2pc.panther_class_id AS CHAR)) = pc.pcid
	AND pc.parent_pcids = 'PC00000'
GROUP BY
	pc.name
ORDER BY
	protein_count DESC")
pandata <- dbGetQuery(con, sql)
print(pandata)
#
#par(mfrow = c(1, 2))
par(mar = c(12,2,2,2))
#
n <- 10
counts <- c(pandata$protein_count[1:n],sum(pandata$protein_count[(n+1):nrow(pandata)]))
labs <- c(pandata$panther_class[1:n],"other")
barplot(counts, names.arg=labs, las=3, col=c(rainbow(n=length(labs)-1),"gray37"))
title(main=sprintf("TCRD Panther Classes\n(top %d)",n))
#
#Other:
#counts <- pandata$protein_count[(n+1):nrow(pandata)]
#labs <- pandata$panther_class[(n+1):nrow(pandata)]
#barplot(counts, names.arg=labs, las=3, col="gray37")
#title(main="other")
#
mtext(text=date(), side=4, outer=T)

###
### Drugs:
sql <- sprintf(
"SELECT
	da.drug,
	da.has_moa,
	da.source,
	t.id,
	t.idgfam,
	t.tdl
FROM
	drug_activity da
LEFT OUTER JOIN
	target t ON da.target_id = t.id
WHERE
	t.tdl IN ('Tclin','Tclin+')
ORDER BY
	da.drug")
drugdata <- dbGetQuery(con, sql)

par(orig.par)

t5 <- table(drugdata[,c('source')])

labs <- rownames(t5)
labs <- paste(labs, sprintf("\n%d (%d%%)",t5, round(t5/sum(t5)*100))) # annotate labels

pie3D(t5, explode=0.1, labelcex=0.7, labels=labs)
title(main=sprintf("TCRD & DrugCentral MoA source\ntotal = %d",sum(t5)))
mtext(text=date(), side=4, outer=T)


#par(mfrow = c(2, 2))
#par(mar = c(0,0,1,0))
#par(oma = c(1,0,2,1))
#t4 <- table(drugdata[,c('source','idgfam')])
#print(t4)
#for (idgfam in colnames(t4))
#{
#  pie3D(t4[,idgfam], explode=0.1, labelcex=0.7)
#  title(main=sprintf("%s",idgfam))
#}
#mtext(text="TCRD & DrugCentral source", side=3, outer=T)
#mtext(text=date(), side=4, outer=T)

###
par(orig.par)


#############################################################################
if (!interactive())
{
  dev.off()
}
print(sprintf("elapsed time (total): %.2fs",(proc.time()-t0)[3]))
dbDisconnect(con)
