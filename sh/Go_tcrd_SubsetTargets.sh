#!/bin/sh
#############################################################################
### Go_tcrd_SubsetTargets.sh
### 
#############################################################################
#
set -e
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrdev"
#
TDLS="Tdark Tgray Tmacro Tchem Tclin"
#
for tdl in $TDLS ; do
	tcrd_app.py \
		--v \
		--list_targets \
		--idg \
		--tdl ${tdl} \
		--dbname $DBNAME \
		--dbhost $DBHOST \
		--dbuser $DBUSER \
		--dbpw $DBPW \
		--o data/tcrd_tdl_${tdl}.csv
done
#
PFAMS="GPCR IC Kinase NR"
#
for pfam in $PFAMS ; do
	tcrd_app.py \
		--v \
		--list_targets \
		--idg \
		--pfam ${pfam} \
		--dbname $DBNAME \
		--dbhost $DBHOST \
		--dbuser $DBUSER \
		--dbpw $DBPW \
		--o data/tcrd_pfam_${pfam}.csv
done
#
