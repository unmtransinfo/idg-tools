#!/bin/sh
#
#
DBHOST="juniper.health.unm.edu"
DBNAME="tcrd"
DBUSR="jjyang"
DBPW="assword"
#
#
MYSQL="mysql"
#
help() {
	echo "syntax: `basename $0` [options]"
	echo ""
	echo "  required:"
	echo "        -f FILE ........ SQL file"
	echo "  or"
	echo "        -q QUERY ....... SQL"
	echo ""
	echo "  parameters:"
	echo "        -n NAME ........ db name [$DBNAME]"
	echo "        -h HOST ........ db host [$DBHOST]"
	echo "        -z PORT ........ db port [$DBPORT]"
	echo "        -u USR ......... db user [$DBUSR]"
	echo "        -p PW .......... db password"
	echo "  options:"
	echo "        -t ............. TSV output"
	echo "        -v ............. verbose"
	echo ""
	echo "$EXE version: `$MYSQL -V`"
	exit 1
}
#
if [ $# -eq 0 ]; then
	help
fi
#
CSV=""
TSV=""
VERBOSE=""
### Parse options
while getopts f:q:n:h:z:u:p:o:ctv opt ; do
	case "$opt"
	in
	f)      SQLFILE=$OPTARG ;;
	q)      SQL=$OPTARG ;;
	n)      DBNAME=$OPTARG ;;
	h)      DBHOST=$OPTARG ;;
	z)      DBPORT=$OPTARG ;;
	u)      DBUSR=$OPTARG ;;
	p)      DBPW=$OPTARG ;;
	c)      CSV="TRUE" ;;
	t)      TSV="TRUE" ;;
	v)      VERBOSE="TRUE" ;;
	\?)     help
		exit 1 ;;
	esac
done
#
if [ ! "$SQL" -a ! "$SQLFILE" ]; then
	echo "-f or -q required."
	help
fi
#
DBOPTS="-At"
#
if [ "$TSV" ]; then
	DBOPTS="-ABr"
elif [ "$CSV" ]; then
	DBOPTS="-ABr"
else
	DBOPTS="-At"
fi
#
cmd="$MYSQL $DBOPTS -h $DBHOST -p$DBPW -u $DBUSR $DBNAME"
if [ "$VERBOSE" ]; then
	echo "$cmd"
fi
#
if [ "$SQLFILE" ]; then
	$cmd <$SQLFILE
else
	echo "$SQL" |$cmd
fi
#
