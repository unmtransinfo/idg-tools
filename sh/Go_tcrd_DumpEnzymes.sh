#!/bin/sh
#############################################################################
### Dump enzymes.
###
#############################################################################
#
set -e
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrd"
#
tsvfile="data/tcrd_enzymes.tsv"
csvfile="data/tcrd_enzymes.csv"
#
mysql -h $DBHOST -r $DBNAME <<__EOF__ >$tsvfile
SELECT
	id,
	protein.uniprot,
	protein.geneid,
	protein.sym,
	protein.family,
	protein.name
FROM
	protein
WHERE
	family LIKE '%ase %'
	OR family LIKE '%ase) %'
	OR family LIKE '%ase-like %'
	OR family LIKE '%ases %'
	;
--
__EOF__
#
csv_utils.py \
	--tsv2csv \
	--i $tsvfile \
	--o $csvfile
#
uniprotfile="data/tcrd_enzymes.uniprot"
csv_utils.py \
	--extractcol \
	--coltag "uniprot" \
	--i $csvfile \
	--o $uniprotfile
