#!/bin/sh
#############################################################################
### Go_tcrd_ddhtml.sh - data dictionary HTML
### 
### Jeremy Yang
#############################################################################
#
set -e
#set -x
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrd"
DBUSR="jjyang"
#
#Is there a better way to list tables?
TABLES=`mysqlshow -h $DBHOST -u $DBUSR ${DBNAME} \
	|grep '^|.*|$' \
	|perl -pe 's/^\|\s*(\S*)\s*\|$/$1/' \
	|grep -v '^Tables$' \
	|perl -pe 's/[\n\r]/ /g'`
#
#
printf "<HTML>\n"
printf "<HEAD><TITLE>TCRD data dictionary</TITLE></HEAD>\n"
printf "<BODY>\n"
printf "<H1>TCRD data dictionary</H1>\n"
printf "<OL>\n"
for table in $TABLES ; do
	printf "<LI><A HREF=\"#${table}\">${table}</A>\n"
done
printf "</OL>\n"
for table in $TABLES ; do
	#
	printf "<H2><A NAME=\"${table}\">$table</H2><BLOCKQUOTE>\n"
	mysql --html -h $DBHOST -u $DBUSR -e "DESCRIBE $DBNAME.${table}" $DBNAME
	printf "</BLOCKQUOTE>\n"
	#
done
printf "</BODY>\n"
printf "</HTML>\n"
