#!/usr/bin/env python3
#############################################################################
### Pharos  REST API client
###
### https://pharos.nih.gov/idg/api/v1/targets(589)
#############################################################################
import sys,os,argparse,json,re,time,logging
#
import rest_utils
#
API_HOST="pharos.nih.gov"
API_BASE_PATH="/idg/api/v1"
#
#
#############################################################################
def GetTargets(base_url, ids, idtype, fout, verbose):
  tags=[]; n_out=0;
  for id_this in ids:
    url=base_url+'/targets(%s)'%id_this
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    if not rval:
      logging.debug('not found: %s'%(id_this))
      continue
    tgt = rval
    if not tags:
      for tag in tgt.keys():
        if not tag.startswith('_') and (type(tgt[tag]) not in (list, dict)):
          tags.append(tag)
      fout.write('\t'.join(tags)+'\n')
    vals=[];
    for tag in tags:
      val=(tgt[tag] if tag in tgt else '')
      vals.append('' if val is None else str(val))
    fout.write('\t'.join(vals)+'\n')
    n_out+=1
  logging.info('n_in: %d; n_out: %d'%(len(ids), n_out))

#############################################################################
def ListItems(mode, base_url, fout, verbose):
  n_out=0; tags=[]; top=100; skip=0;
  while True:
    url=base_url+'/%s?top=%d&skip=%d'%(mode, top, skip)
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    if not rval:
      break
    elif type(rval) is not dict:
      logging.info('ERROR: rval="%s"'%(str(rval)))
      break
    logging.debug(json.dumps(rval, indent=2))
    count = rval['count'] if 'count' in rval else None
    total = rval['total'] if 'total' in rval else None
    uri = rval['uri'] if 'uri' in rval else None
    logging.debug('uri="%s"'%(uri))
    items = rval['content']
    if not items: break
    for item in items:
      if not tags:
        for tag in item.keys():
          if not tag.startswith('_') and (type(item[tag]) not in (list, dict)):
            tags.append(tag)
        fout.write('\t'.join(tags)+'\n')
      vals=[];
      for tag in tags:
        val=(item[tag] if tag in item else '')
        vals.append('' if val is None else str(val))
      fout.write('\t'.join(vals)+'\n')
      n_out+=1
    skip+=top
  logging.info('n_out = %d'%(n_out))

#############################################################################
if __name__=='__main__':
  PROG=os.path.basename(sys.argv[0])

  parser = argparse.ArgumentParser(description='Pharos REST API client utility')
  idtypes = ['IDG_TARGET_ID', 'UNIPROT', 'ENSP', 'GSYMB']
  ops = ['listTargets', 'getTargets', 'listDiseases', 'getDiseases', 'searchDiseases']
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--i", dest="ifile", help="input file, target IDs")
  parser.add_argument("--id", dest="id", help="ID, target")
  parser.add_argument("--ids", dest="ids", help="IDs, target, comma-separated")
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("--idtype", default='IDG_TARGET_ID', help="target ID type")
  parser.add_argument("--nmax", type=int, help="max to return")
  parser.add_argument("--api_host", default=API_HOST)
  parser.add_argument("--api_base_path", default=API_BASE_PATH)
  parser.add_argument("-v", "--verbose", default=0, action="count")

  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(
	logging.DEBUG if args.verbose>1 else logging.INFO))

  BASE_URL='https://'+args.api_host+args.api_base_path

  if args.ofile:
    fout=open(args.ofile,"w+")
    if not fout: parser.error('ERROR: cannot open outfile: %s'%args.ofile)
  else:
    fout=sys.stdout

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
      logging.info('input IDs: %d'%(len(ids)))
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
    GetTargets(BASE_URL, ids, args.idtype, fout, args.verbose)

  elif args.op=='listTargets':
    ListItems('targets', BASE_URL, fout, args.verbose)

  elif args.op=='listDiseases':
    ListItems('diseases', BASE_URL, fout, args.verbose)

  elif args.op=='getDiseases':
    logging.info('ERROR: not implemented yet.')

  elif args.op=='searchDiseases':
    logging.info('ERROR: not implemented yet.')

  else:
    parser.print_help()

  logging.info(('%s: elapsed time: %s'%(PROG,time.strftime('%Hh:%Mm:%Ss',time.gmtime(time.time()-t0)))))
