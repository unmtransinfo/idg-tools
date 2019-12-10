#!/bin/sh
#
obo2csv.py --i ../data/doid.obo --o data/doid.csv
#
csv_utils.py \
	--i data/doid.csv \
	--coltags "id,name,is_a" \
	--subsetcols \
	--overwrite_input_file
#
csv_utils.py \
	--i data/doid.csv \
	--csv2tsv \
	--o data/doid.tsv
#
rm -f data/doid.graphml
touch data/doid.graphml
#
cat <<__EOF__ >> data/doid.graphml
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
	http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <key id="author" for="graph" attr.name="author" attr.type="string"/>
  <key id="name" for="graph" attr.name="name" attr.type="string"/>
  <key id="name" for="node" attr.name="name" attr.type="string"/>
  <key id="uri" for="node" attr.name="uri" attr.type="string"/>
  <key id="doid" for="node" attr.name="doid" attr.type="string"/>
  <key id="type" for="edge" attr.name="type" attr.type="string"/>
  <graph id="DO_CLASS_HIERARCHY" edgedefault="directed">
    <data key="name">Disease Ontology class hierarchy</data>
__EOF__
#
cat \
	data/doid.tsv \
	|sed -e '1d' \
	|perl -pe 's/"\t"/\t/g' \
	|perl -pe 's/^"(.*)"(\s*)$/$1$2/' \
	|perl -ne '@_=split(/\t/,$_); print "\t<node id=\"$_[0]\"><data key=\"doid\">$_[0]</data><data key=\"name\">$_[1]</data></node>\n"' \
	>> data/doid.graphml
#
cat \
	data/doid.tsv \
	|sed -e '1d' \
	|perl -pe 's/"\t"/\t/g' \
	|perl -pe 's/^"(.*)"(\s*)$/$1$2/' \
	|perl -ne 's/[\n\r]//g; @f=split(/\t/,$_); @tgts=split(/;/,$f[2]); foreach $t (@tgts) { print "$f[0]\t$f[1]\t$t\n" }' \
	|perl -ne 's/[\n\r]//g; @_=split(/\t/,$_); print "\t<edge source=\"$_[2]\" target=\"$_[0]\"><data key=\"type\">subclass</data></edge>\n"' \
	>> data/doid.graphml
#
cat <<__EOF__ >> data/doid.graphml
  </graph>
</graphml>
__EOF__
#
###
#
igraph_utils.py --i data/doid.graphml --summary
#
igraph_utils.py --i data/doid.graphml --rootnodes --vvv
#
igraph_utils.py \
	--i data/doid.graphml \
	--shortest_path \
	--nidA "DOID:0014667" \
	--nidB "DOID:0050179"
#
###
#
./dag_ic.py -v \
	--i data/doid.graphml \
	--o data/doid_ic.graphml \
	computeIC
#
