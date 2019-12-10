#! /usr/bin/env python3
"""
	obo2csv.py - used on doid.obo (Disease Ontology)

	Jeremy J Yang
"""
import sys,os,argparse,re,csv

PROG=os.path.basename(sys.argv[0])

#############################################################################
def OBO2CSV(fin, fout, verbose):
  n_in=0; n_rec=0; n_out=0;
  tags = ['id','name','namespace','alt_id','def','subset','synonym','xref','is_a','is_obsolete']
  fout.write('\t'.join(tags)+'\n')
  reclines=[];
  while True:
    line=fin.readline()
    if not line: break
    n_in+=1
    line=line.strip()
    if reclines:
      if line == '':
        row = OBO2CSV_Record(reclines, verbose)
        n_rec+=1
        vals=[]
        is_obsolete=False
        for tag in tags:
          if tag in row:
            val=row[tag]
            if tag in ('def','synonym'):
              val=re.sub(r'^"([^"]*)".*$', r'\1', val)
            else:
              val=re.sub(r'^"(.*)"$', r'\1', val)
          else:
            val=''
          if tag=='is_obsolete': is_obsolete = bool(val.lower() == "true")
          vals.append(val)
        if not is_obsolete:
          fout.write('\t'.join(vals)+'\n')
          n_out+=1
        reclines=[];
      else:
        reclines.append(line)
    else:
      if line == '[Term]':
        reclines.append(line)
      else: continue

  print('input lines: %d'%(n_in), file=sys.stderr)
  print('input records: %d'%(n_rec), file=sys.stderr)
  print('output lines: %d'%(n_out), file=sys.stderr)

#############################################################################
def OBO2CSV_Record(reclines, verbose):
  vals={};
  if reclines[0] != '[Term]':
    print('ERROR: reclines[0] = "%s"'%reclines[0], file=sys.stderr)
    return
  for line in reclines[1:]:
    line = re.sub(r'\s*!.*$','',line)
    k,v = re.split(r':\s*', line, maxsplit=1)
    if k=='xref' and not re.match(r'\S+:\S+$',v): continue
    if k not in vals: vals[k]=''
    vals[k] = '%s%s%s'%(vals[k],(';' if vals[k] else ''),v)
  return vals

#############################################################################
if __name__=='__main__':

  parser = argparse.ArgumentParser(description='OBO to TSV converter')
  parser.add_argument("--i", dest="ifile", help="input OBO file")
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("-v", "--verbose", action="count")
  args = parser.parse_args()

  if not args.ifile:
    parser.error('Input file required.')

  fin = open(args.ifile)

  if args.ofile:
    fout=open(args.ofile,"w+")
  else:
    fout=sys.stdout

  OBO2CSV(fin, fout, args.verbose)
