#!/bin/sh
#############################################################################
#
set -e
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrd"
#
tcrd_dbclient.py \
	--v \
	--list_targets \
	--dbname $DBNAME \
	--dbhost $DBHOST \
	--o data/tcrd_targets.csv
#
