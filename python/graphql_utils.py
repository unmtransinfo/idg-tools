#!/usr/bin/env python3
###
import sys,os,argparse,logging

import gql
from gql.transport.requests import RequestsHTTPTransport

#############################################################################
if __name__ == "__main__":

  #API_URL = "https://ncats-ifx.appspot.com/graphql"
  API_URL = "https://pharos-api.ncats.io/graphql"

  parser = argparse.ArgumentParser(description='Pharos GraphQL client utility')
  ops = ['query', 'test', 'getSchema']
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--i", dest="ifile", help="input file, GraphQL")
  parser.add_argument("--graphql", help="input GraphQL")
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("--api_url", default=API_URL)
  parser.add_argument("-v", "--verbose", default=0, action="count")

  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  _transport = RequestsHTTPTransport(args.api_url)
  client = gql.Client(transport=_transport, fetch_schema_from_transport=False)

  logging.debug("client.schema: \"%s\""%client.schema)

  if args.ifile:
    with open(args.ifile) as fin:
      graphql = fin.read()
  elif args.graphql:
    graphql = args.graphql
  else:
    graphql = None

  logging.debug(graphql)

  if args.op == 'query':
    if not graphql: parser.error("--i or --graphql required.")
    try:
      query = gql.gql(graphql)
      rval = client.execute(query)
      print(rval)
    except Exception as e:
      print(e)

  elif args.op == 'getSchema':
    parser.error("Unimplemented operation: %s"%args.op)

  else:
    parser.error("Invalid operation: %s"%args.op)

