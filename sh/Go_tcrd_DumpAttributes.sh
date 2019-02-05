#!/bin/sh
#############################################################################
### Dump attributes, to gene and attr_count table.
###
### Jeremy Yang
###  14 Aug 2015
#############################################################################
#
set -e
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrd"
DBUSR="jjyang"
#
###
# ChEA
###
tsvfile="data/tcrd_attr_chea.tsv"
#
mysql -h $DBHOST -u $DBUSR -r $DBNAME <<__EOF__ >$tsvfile
--
SELECT
	p.sym AS "gene_symb",
	SUM(CAST(ga.value AS DECIMAL)) AS "attr_count"
FROM
	protein p
LEFT JOIN
	gene_attribute ga ON ga.protein_id = p.id
WHERE
	ga.type = 'TF ChEA'
GROUP BY
	p.sym
ORDER BY
	p.sym
	;
--
__EOF__
#
csv_utils.py --v --i $tsvfile --tsv --colvalstats --coltag "attr_count"
#
N=`csv_utils.py --v --i $tsvfile --tsv --size 2>&1 |sed -e 's/^.*rows: \([0-9]*\).*$/\1/'`
#
mpl_utils.py \
	--v \
	--i $tsvfile \
	--tsv \
	--o "${tsvfile}.png" \
	--xcoltag "attr_count" \
	--hist \
	--hist_trunc \
	--ylabel "gene_count (N=$N)" --xlabel "attribute_count" \
	--title "TF ChEA gene attribute count distribution (empirical)"
#
okular ${tsvfile}.png &
#
#
###
# NURSA
###
tsvfile="data/tcrd_attr_nursa.tsv"
#
mysql -h $DBHOST -u $DBUSR -r $DBNAME <<__EOF__ >$tsvfile
--
SELECT
	p.sym AS "gene_symb",
	SUM(CAST(ga.value AS DECIMAL)) AS "attr_count"
FROM
	protein p
LEFT JOIN
	gene_attribute ga ON ga.protein_id = p.id
WHERE
	ga.type = 'IP NURSA'
GROUP BY
	p.sym
ORDER BY
	p.sym
	;
--
__EOF__
#
csv_utils.py --v --i $tsvfile --tsv --colvalstats --coltag "attr_count"
#
N=`csv_utils.py --v --i $tsvfile --tsv --size 2>&1 |sed -e 's/^.*rows: \([0-9]*\).*$/\1/'`
#
mpl_utils.py \
	--v \
	--i $tsvfile \
	--tsv \
	--o "${tsvfile}.png" \
	--xcoltag "attr_count" \
	--hist \
	--hist_trunc \
	--ylabel "gene_count (N=$N)" --xlabel "attribute_count" \
	--title "IP NURSA gene attribute count distribution (empirical)"
#
okular ${tsvfile}.png &
#
###
# Pathways
###
tsvfile="data/tcrd_attr_pathway.tsv"
#
mysql -h $DBHOST -u $DBUSR -r $DBNAME <<__EOF__ >$tsvfile
--
SELECT
	p.sym AS "gene_symb",
	COUNT(t2p.id) AS "attr_count"
FROM
	protein p
JOIN
	t2tc ON p.id = t2tc.protein_id
JOIN
	target t ON t.id = t2tc.target_id
JOIN
	target2pathway t2p ON t.id = t2p.target_id
GROUP BY
	p.sym
ORDER BY
	p.sym
	;
--
__EOF__
#
csv_utils.py --v --i $tsvfile --tsv --colvalstats --coltag "attr_count"
#
N=`csv_utils.py --v --i $tsvfile --tsv --size 2>&1 |sed -e 's/^.*rows: \([0-9]*\).*$/\1/'`
#
mpl_utils.py \
	--v \
	--i $tsvfile \
	--tsv \
	--o "${tsvfile}.png" \
	--xcoltag "attr_count" \
	--hist \
	--hist_trunc \
	--ylabel "gene_count (N=$N)" --xlabel "attribute_count" \
	--title "Pathways gene attribute count distribution (empirical)"
#
okular ${tsvfile}.png &
#
