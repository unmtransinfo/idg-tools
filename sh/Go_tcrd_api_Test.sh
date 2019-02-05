#!/bin/sh
#
set -x
#
#API_HOST="habanero.health.unm.edu"
API_HOST="juniper.health.unm.edu"
API_BASEPATH="/tcrd/api"
BASE_URL="http://${API_HOST}${API_BASEPATH}"
#
rest_request.py "$BASE_URL/_info"
#
rest_request.py "$BASE_URL/target?q={\"id\":17}"
rest_request.py "$BASE_URL/target?q={\"genesymb\":\"GPER1\"}"
rest_request.py "$BASE_URL/target?q={\"geneid\":2852}"
rest_request.py "$BASE_URL/target?q={\"uniprot\":\"P30450\"}"
rest_request.py "$BASE_URL/target?q={\"genesymb\":\"GPER1\"}&expand=true"
#
rest_request.py "$BASE_URL/target?q={\"pfam\":\"GPCR\",\"tdl\":\"Tclin\"}"
#
