#!/usr/bin/env python3
###
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport

_transport = RequestsHTTPTransport("https://ncats-ifx.appspot.com/graphql")
client = Client(transport=_transport, fetch_schema_from_transport=False)

print("DEBUG: client.schema: \"%s\""%client.schema)

query = gql("""
{
  search(term: "+lymphoma") {
    targetResult {
      count
      targets {
        sym
        tdl
        name
        description
        novelty
        diseases {
          name
          associations {
            did
            type
          }
        }
      }
    }
  }
}
""")

try:
  rval = client.execute(query)
  print(rval)
except Exception as e:
  print(e)

