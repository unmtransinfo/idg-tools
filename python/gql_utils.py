#!/usr/bin/env python3
###
import sys,os,argparse
import gql.gql, gql.Client

client = gql.Client(schema=schema)

query = gql('''
{
  hello
}
''')

client.execute(query)
