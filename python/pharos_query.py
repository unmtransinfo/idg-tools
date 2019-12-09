#!/usr/bin/env python
#############################################################################
### Pharos  REST API client
###
### https://pharos.nih.gov/idg/api/v1/targets(589)
#############################################################################
#############################################################################
### Jeremy Yang
#############################################################################
import sys,os,argparse,re,types
import json,codecs,csv
import urllib2,requests,time
#
import rest_utils_py2 as rest_utils
#
API_HOST="pharos.nih.gov"
API_BASE_PATH="/idg/api/v1"
API_BASE_URL='https://'+API_HOST+API_BASE_PATH
#
#
#############################################################################
def GetTargets(base_url,tids,fout,verbose):
  n_out=0;
  tags=[];
  for tid in tids:
    url=base_url+'/targets(%s)'%tid
    rval=rest_utils.GetURL(url,parse_json=True,verbose=verbose)
    if not rval:
      if verbose:
        print >>sys.stderr, 'not found: %s'%(tid)
      continue
    tgt = rval
    if not tags:
      for tag in tgt.keys():
        if not tag.startswith('_') and (type(tgt[tag]) not in (types.ListType, types.DictType)):
          tags.append(tag)
      fout.write('\t'.join(tags)+'\n')

    vals = [];
    for tag in tags:
      val=(tgt[tag] if tgt.has_key(tag) else '')
      vals.append('' if val is None else str(val))
    fout.write('\t'.join(vals)+'\n')
    n_out+=1

  print >>sys.stderr, 'n_in = %d'%(len(tids))
  print >>sys.stderr, 'n_out = %d'%(n_out)

#############################################################################
def ListItems(mode,base_url,fout,verbose):
  n_out=0; tags=[]; top=100; skip=0;
  while True:
    url=base_url+'/%s?top=%d&skip=%d'%(mode,top,skip)
    rval=rest_utils.GetURL(url,parse_json=True,verbose=verbose)
    if not rval:
      break
    elif type(rval) != types.DictType:
      print >>sys.stderr, 'ERROR: rval="%s"'%(str(rval))
      break
    if verbose>2:
      print >>sys.stderr, json.dumps(rval, indent=2)
    count = rval['count'] if rval.has_key('count') else None
    total = rval['total'] if rval.has_key('total') else None
    uri = rval['uri'] if rval.has_key('uri') else None
    print >>sys.stderr, 'DEBUG: uri="%s"'%(uri)
    items = rval['content']
    if not items: break
    for item in items:
      if not tags:
        for tag in item.keys():
          if not tag.startswith('_') and (type(item[tag]) not in (types.ListType, types.DictType)):
            tags.append(tag)
        fout.write('\t'.join(tags)+'\n')
      vals=[];
      for tag in tags:
        val=(item[tag] if item.has_key(tag) else '')
        vals.append('' if val is None else str(val))
      fout.write('\t'.join(vals)+'\n')
      n_out+=1
    skip+=top
  print >>sys.stderr, 'n_out = %d'%(n_out)

#############################################################################
if __name__=='__main__':
  PROG=os.path.basename(sys.argv[0])

  parser = argparse.ArgumentParser(
	description='Pharos REST API client utility',
	epilog='BASE_URL: %s'%API_BASE_URL)
  ops = ['listTargets', 'getTargets', 'listDiseases', 'getDiseases', 'searchDiseases']
  parser.add_argument("op",choices=ops,help='operation')
  parser.add_argument("--id",dest="id",help="ID, target (any type)")
  parser.add_argument("--ids",dest="ids",help="IDs, target, comma-separated")
  parser.add_argument("--i",dest="ifile",help="input file, PubMed IDs")
  parser.add_argument("--nmax",help="list: max to return")
  parser.add_argument("--o",dest="ofile",help="output (TSV)")
  parser.add_argument("-v","--verbose",action="count")

  args = parser.parse_args()

  if args.ofile:
    #fout=open(args.ofile,"w+")
    fout=codecs.open(args.ofile,"w","utf8","replace")
    if not fout: ErrorExit('ERROR: cannot open outfile: %s'%args.ofile)
  else:
    #fout=sys.stdout
    fout=codecs.getwriter('utf8')(sys.stdout,errors="replace")

  ids=[];
  if args.ifile:
    fin=open(args.ifile)
    if not fin:
      parser.error('ERROR: cannot open ifile: %s'%args.ifile)
      parser.exit()
    while True:
      line=fin.readline()
      if not line: break
      ids.append(line.rstrip())
    if args.verbose:
      print >>sys.stderr, 'input IDs: %d'%(len(ids))
    fin.close()
  elif args.ids:
    ids = re.split(r'\s*,\s*',args.ids.strip())
  elif args.id:
    ids.append(args.id)

  t0 = time.time()

  if args.op=='getTargets':
    if not ids:
      parser.error('get requires TID[s].')
      parser.exit()
    GetTargets(API_BASE_URL, ids, fout, args.verbose)

  elif args.op=='listTargets':
    ListItems('targets', API_BASE_URL, fout, args.verbose)

  elif args.op=='listDiseases':
    ListItems('diseases', API_BASE_URL, fout, args.verbose)

  elif args.op=='getDiseases':
    print >>sys.stderr, 'ERROR: not implemented yet.'

  elif args.op=='searchDiseases':
    print >>sys.stderr, 'ERROR: not implemented yet.'

  else:
    parser.print_help()

  print >>sys.stderr, ('%s: elapsed time: %s'%(PROG,time.strftime('%Hh:%Mm:%Ss',time.gmtime(time.time()-t0))))
