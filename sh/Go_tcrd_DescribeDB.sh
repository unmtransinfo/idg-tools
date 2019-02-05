#!/bin/sh
#############################################################################
### Go_tcrd_DescribeDB.sh
### 
### Table name underscores must be escaped for mysqlshow.
### 
### Jeremy Yang
### 28 Apr 2015
#############################################################################
#
set -e
#set -x
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrd"
#DBNAME="tcrdev"
DBUSR="jjyang"
DBPW="assword"
#
#Is there a better way to list tables?
TABLES=`mysqlshow -h $DBHOST -u $DBUSR -p${DBPW} ${DBNAME} \
	|grep '^|.*|$' \
	|perl -pe 's/^\|\s*(\S*)\s*\|$/$1/' \
	|grep -v '^Tables$' \
	|perl -pe 's/[\n\r]/ /g'`
#
echo "TABLES:"
for table in $TABLES ; do
	printf "\t%s\n" $table
done
#
for table in $TABLES ; do
	#
	t=`echo $table |sed -e 's/_/\\\\_/g'`
	#
	mysqlshow -h $DBHOST -u $DBUSR -p${DBPW} "${DBNAME}" "${t}"
	mysql -h $DBHOST -u $DBUSR -p${DBPW} -e "SELECT COUNT(*) AS ${table}_count FROM $DBNAME.${table}"
	printf "\n"
	#
done
