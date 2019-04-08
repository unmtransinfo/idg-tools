#!/usr/bin/env python3
#############################################################################
### IMPC API Client
### GPA = Genotype-phenotype association
### https://www.mousephenotype.org/data/documentation/data-access
### Warning: Datatype variability across phenotyping centers.
#############################################################################
import sys,os,argparse,json
import urllib, urllib.request, urllib.parse

API_HOST="www.ebi.ac.uk"
API_BASE_URL="/mi/impc/solr"

N_CHUNK=1000

PHENOTYPING_CENTERS=[
	'BCM',
	'CMHD', #Monterotondo?
	'HMGU',
	'JAX',
	'KMPC',
	'MRC Harwell',
	'ICS',
	'MARC',
	'RBRC',
	'TCP',
	'UC Davis',
	'WTSI' ]
#	'CIPHE'
#	'CDTA'
#	'SEAT
#	'CCP-IMG'

#############################################################################
def GetURL(url, verbose=0):
  if verbose:
    print('url="%s"'%url,file=sys.stderr)
  req=urllib.request.Request(url=url)
  if verbose>1:
    print('request type = %s'%req.type,file=sys.stderr)
    print('request method = %s'%req.get_method(),file=sys.stderr)
    print('request host = %s'%req.host,file=sys.stderr)
    print('request full_url = %s'%req.full_url,file=sys.stderr)
    print('request header_items = %s'%req.header_items(),file=sys.stderr)

  try:
    with urllib.request.urlopen(req) as f:
      fbytes=f.read() #With Python3 read bytes from sockets.
      ftxt=fbytes.decode('utf-8')
  except Exception as e:
    print('Error (Exception): %s'%e,file=sys.stderr)
    return None

  return ftxt

#############################################################################
def GetGPAsByCenter(args, fout):
  args.id_type = 'phenotyping_center'
  GetGPAsByID([args.phenotyping_center], args, fout)

#############################################################################
def GetGPAsByID(ids, args, fout):
  '''E.g. /genotype-phenotype/select?q=mp_term_id:"MP:0001262"'''
  service="genotype-phenotype"
  url_base=('https://'+API_HOST+API_BASE_URL+'/'+service+'/select?')
  tags=None; n_thing=0;
  for id_this in ids:
    qry=(('%s:'%args.id_type)+urllib.parse.quote('"%s"'%(id_this), safe=':'))
    url_this_id=url_base+('q=%s'%(qry))
    i_chunk=0;
    while True:
      url=url_this_id+('&start=%d&rows=%d'%(args.skip+i_chunk*N_CHUNK, N_CHUNK))
      try:
        response = GetURL(url, verbose=args.verbose)
      except:
        break
      if not response:
        break
      things = json.loads(response, encoding='utf-8')
      things = things['response']['docs']
      if not things: break
      for thing in things:
        n_thing+=1
        if not tags:
          tags = thing.keys()
          fout.write('\t'.join(tags)+'\n')
        vals = []
        for tag in tags:
          if tag not in thing:
            vals.append('')
          elif type(thing[tag]) in (list, tuple):
            vals.append(';'.join([str(x) for x in thing[tag]]))
          else:
            vals.append(str(thing[tag]))
        fout.write('\t'.join(vals)+'\n')
        if n_thing==args.nmax: break
      i_chunk+=1
  print('%s: %d'%(service, n_thing), file=sys.stderr)

#############################################################################
def GetGPAs_All(args, fout):
  '''NOT WORKING WELL: due to variability in datatypes across centers.'''
  service="genotype-phenotype"
  url_base=('https://'+API_HOST+API_BASE_URL+'/'+service+'/select?q=*:*')
  tags=None; n_thing=0;
  i_chunk=0;
  while True:
    url=url_base+('&start=%d&rows=%d'%(args.skip+i_chunk*N_CHUNK, N_CHUNK))
    try:
      response = GetURL(url, verbose=args.verbose)
    except:
      break
    if not response:
      break
    things = json.loads(response, encoding='utf-8')
    things = things['response']['docs']
    if not things: break
    for thing in things:
      n_thing+=1
      if not tags:
        tags = thing.keys()
        fout.write('\t'.join(tags)+'\n')
      vals = []
      for tag in tags:
        if tag not in thing:
          vals.append('')
        elif type(thing[tag]) in (list, tuple):
          vals.append(';'.join([str(x) for x in thing[tag]]))
        else:
          vals.append(str(thing[tag]))
      fout.write('\t'.join(vals)+'\n')
      if n_thing==args.nmax: break
    i_chunk+=1
  print('%s: %d'%(service, n_thing), file=sys.stderr)

#############################################################################
if __name__=="__main__":
  PROG=os.path.basename(sys.argv[0])
  epilog='Example mp_term_id: "MP:0001262"; mp_term_name: "decreased body weight"'
  parser = argparse.ArgumentParser(description='IMPC REST API client utility',
	epilog=epilog)
  ops = ['getGPAsByID', 'getGPAs_all', 'getGPAsByCenter',
	'listPhenotypingCenters']
  idtypes=['mp_term_id', 'mp_term_name']
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--id_type", choices=idtypes, help='query ID type, e.g. mp_term_id')
  parser.add_argument("--id", help="ID, e.g. MP term ID or name")
  #parser.add_argument("--phenotyping_center", choices=PHENOTYPING_CENTERS)
  parser.add_argument("--phenotyping_center")
  parser.add_argument("--ifile", help="input file, IDs")
  parser.add_argument("--nmax", type=int, help="max results")
  parser.add_argument("--skip", type=int, help="skip results", default=0)
  parser.add_argument("--o", dest="ofile", help="output (CSV)")
  parser.add_argument("-v", "--verbose", dest="verbose", action="count", default=0)

  args = parser.parse_args()

  if args.ofile:
    fout=open(args.ofile,"w+")
    if not fout: parser.error('ERROR: cannot open outfile: %s'%args.ofile)
  else:
    fout=sys.stdout

  ids=[];
  if args.ifile:
    fin=open(args.ifile)
    if not fin: parser.error('ERROR: cannot open: %s'%args.ifile)
    while True:
      line=fin.readline()
      if not line: break
      ids.append(line.rstrip())
    if args.verbose:
      print('%s: input queries: %d'%(PROG,len(ids)),file=sys.stderr)
    fin.close()
  elif args.id:
    ids.append(args.id)

  if args.op=='getGPAsByID':
    if not ids: parser.error('--id or --ifile required.')
    GetGPAsByID(ids, args, fout)

  elif args.op=='getGPAsByCenter':
    if not args.phenotyping_center: parser.error('--phenotyping_center required.')
    GetGPAsByCenter(args, fout)

  elif args.op=='getGPAs_all':
    print('WARNING: not working well due to datatype variability across centers.',file=sys.stderr)
    GetGPAs_All(args, fout)

  elif args.op=='listPhenotypingCenters':
    print('\n'.join(PHENOTYPING_CENTERS))

  else:
    parser.print_help()
