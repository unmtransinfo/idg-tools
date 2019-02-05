tcrd <- read.csv("~/Downloads/TCRD_v157_GTExHPMHPA/TCRD_v157_GTExHPMHPA.csv",
                 stringsAsFactors=F
)

tissues <- data.frame(t(tcrd[1:4,-1]))

colnames(tissues) <- c("NrCrt","Source","BTO_ID","Name")

#Rm extra header rows.
tcrd <- tcrd[5:nrow(tcrd),]

rownames(tcrd) <- tcrd[,1] #UniProt to rownames
tcrd[,1] <- NULL
colnames(tcrd) <- tissues$Name

tissues$Type <- as.character(rownames(tissues))
tissues$Type <- gsub(".[0-9]+$", "", tissues$Type)

tissues$Type <- as.factor(tissues$Type)
tissues$Source <- as.factor(tissues$Source)

### Now convert "",0,low,medium,high to NA and numeric.

tcrd[tcrd == ""] <- NA
tcrd[tcrd == "Low"] <- "1"
tcrd[tcrd == "Medium"] <- "2"
tcrd[tcrd == "High"] <- "3"

for (j in 1:ncol(tcrd))
{
  tcrd[,j] <- as.integer(tcrd[,j])
}

## Nervous system:

print(sprintf("gene: %s ; sum of all expression: %d\n", "P31946", 
              sum(tcrd["P31946",])))
print(sprintf("gene: %s ; sum of all expression (Nervous.System): %d\n", "P31946", 
              sum(tcrd["P31946",tissues[which(tissues$Type == "Nervous.System"),]$Name])))
print(sprintf("gene: %s ; sum of all expression (NOT Nervous.System): %d\n", "P31946", 
              sum(tcrd["P31946",tissues[which(tissues$Type != "Nervous.System"),]$Name])))

for (i in 1:nrow(tcrd))
{
  tcrd$SumNervous[i] <- sum(tcrd[i,tissues[which(tissues$Type == "Nervous.System"),]$Name])
  tcrd$SumNotNervous[i] <- sum(tcrd[i,tissues[which(tissues$Type != "Nervous.System"),]$Name])
}

plot(tcrd$SumNervous, tcrd$SumNotNervous, pch=18, col="blue")
