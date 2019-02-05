#!/bin/sh
#############################################################################
### MySql
### Create local TCRD tables for joining with prototype data imports,
### such as GWAS and MLP.
#############################################################################
#
DBNAME="tcrd"
DBUSR="jjyang"
#
DATADIR="data"
#
tcrd_app.py \
        --v \
        --list_targets \
        --o ${DATADIR}/tcrd_all.csv
#
mysql -v -u $DBUSR <<__EOF__
CREATE DATABASE $DBNAME;
USE $DBNAME;
__EOF__
#
csvfiles="\
${DATADIR}/tcrd_all.csv"
#
for csvfile in $csvfiles ; do
	#
	sqlfile_create="${csvfile}_create.sql"
	sqlfile_insert="${csvfile}_insert.sql"
	#
	csv2sql.py \
		--dbsystem 'mysql' \
		--i $csvfile \
		--create \
		--schema "$DBNAME" \
		--fixtags \
		--o $sqlfile_create
	#
	mysql -u $DBUSR $DBNAME < $sqlfile_create
	#
	csv2sql.py \
		--dbsystem 'mysql' \
		--i $csvfile \
		--insert \
		--schema "$DBNAME" \
		--fixtags \
		--o $sqlfile_insert
	#
	mysql -u $DBUSR $DBNAME < $sqlfile_insert
	#
done
#
