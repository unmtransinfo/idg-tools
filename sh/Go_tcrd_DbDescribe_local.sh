#!/bin/sh
#
DBNAME="tcrd"
#
tables='tcrd_all'
#
set -x
#
for table in $tables ; do
	t=`echo $table |sed -e 's/_/\\\\_/g'`
	mysqlshow $DBNAME "$t"
done
