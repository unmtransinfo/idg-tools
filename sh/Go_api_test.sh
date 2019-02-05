#!/bin/sh
#
BASE_URI='http://juniper.health.unm.edu/tcrd/api'
#
CMD='rest_request.py --url'
#
set -x
#
$CMD "${BASE_URI}/_info"
$CMD "${BASE_URI}/target?q={\"id\":17}"
$CMD "${BASE_URI}/target?q={\"genesymb\":\"GPER1\"}"
$CMD "${BASE_URI}/target?q={\"geneid\":3105}"
$CMD "${BASE_URI}/target?q={\"uniprot\":\"Q9UP38\"}"
$CMD "${BASE_URI}/target?q={\"idgfam\":\"NR\",\"tdl\":\"Tchem\"}"
$CMD "${BASE_URI}/target?q={\"genesymb\":\"GPER1\"}&raw=TRUE"
$CMD "${BASE_URI}/target?q={\"genesymb\":\"GPER1\"}&expand=TRUE"
#
