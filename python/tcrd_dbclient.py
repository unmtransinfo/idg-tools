#!/usr/bin/env python
'''
	TCRD db client utility (see also REST API client)

	In general, return data as lists and dicts, readily convertible to JSON.

	Jeremy Yang
	14 Aug 2015
'''
import os,sys,getopt,re,time,types,codecs
import json

try:
  import pymysql as mysql
except Exception, e:
  print >>sys.stderr, str(e)
  try:
    import MySQLdb as mysql
  except Exception, e:
    print >>sys.stderr, str(e)
    sys.exit(1)

PROG=os.path.basename(sys.argv[0])

DBHOST='juniper.health.unm.edu'
#DBHOST='habanero.health.unm.edu'
DBNAME='tcrd'
#DBNAME='tcrdev'
DBUSR='jjyang'
DBPW='assword'


TDL={	0:'Tdark',
	1:'Tbio',
	2:'Tchem',
	4:'Tclin'
	}

#############################################################################
def Connect(dbhost,dbname,dbusr,dbpw):
  #dsn='%s:%s:%s:%s'%(dbhost,dbname,dbusr,dbpw)
  #db=mysql.connect(dsn=dsn)
  db=mysql.connect(host=dbhost,user=dbusr,passwd=dbpw,db=dbname)
  return db

#############################################################################
def ListTables(dbname,dbcon):
  cur=dbcon.cursor()
  cur.execute('SHOW TABLES ;')
  rows=cur.fetchall()
  tables=[]
  for row in rows:
    tables.append(row[0])
  tables.sort()
  return tables

#############################################################################
def Info(dbname,dbcon):
  cur=dbcon.cursor(mysql.cursors.DictCursor)
  cur.execute('SELECT * FROM dbinfo ;')
  row=cur.fetchone()
  return row

#############################################################################
def Describe(dbname,dbcon):
  cur=dbcon.cursor()
  outtxt=''
  for table in ListTables(dbname,dbcon):
    outtxt+=('%s:\n'%table)
    cur.execute('DESCRIBE '+table+';')
    row=cur.fetchone()
    cols=[]
    while row:
      cols.append(row[0])
      row=cur.fetchone()
    cols.sort()
    outtxt+=('\t'+(', '.join(cols))+'\n')
  return outtxt

#############################################################################
def Counts(dbname,dbcon):
  tables=ListTables(dbname,dbcon)
  cur=dbcon.cursor()
  outtxt=''
  for table in tables:
    cur.execute('SELECT count(*) FROM '+table+';')
    row=cur.fetchone()
    outtxt+=('%18s: %8d rows\n'%(table,row[0]))
  return outtxt

#############################################################################
def AttributeCounts(dbname,dbcon):
  cur=dbcon.cursor()
  sql='SELECT ga.type, COUNT(ga.id) FROM gene_attribute ga GROUP BY ga.type'
  cur.execute(sql)
  row=cur.fetchone()
  attrcounts={}
  while row:
    attrcounts[row[0]]=row[1]
    row=cur.fetchone()

  outtxt='Attribute counts:\n'
  for attr_type in sorted(attrcounts.keys()):
    outtxt+=('%13s: %8d\n'%(attr_type,attrcounts[attr_type]))
  return outtxt

#############################################################################
def XrefCounts(dbname,dbcon):
  '''Synonyms, aliases, and Xrefs.'''
  cur=dbcon.cursor()
  outtxt=''

  f,t = 'name','synonym'
  cur.execute('SELECT COUNT(DISTINCT %s) FROM %s'%(f,t))
  row=cur.fetchone()
  outtxt+=('%s_count: %8d\n'%(t,row[0]))

  f,t = 'name','alias'
  cur.execute('SELECT COUNT(DISTINCT %s) FROM %s'%(f,t))
  row=cur.fetchone()
  outtxt+=('%s_count: %8d\n'%(t,row[0]))

  f,t = 'value','xref'
  cur.execute('SELECT COUNT(DISTINCT %s) FROM %s'%(f,t))
  row=cur.fetchone()
  outtxt+=('%s_count: %8d\n'%(t,row[0]))

  cur.execute('SELECT xtype, COUNT(DISTINCT value) FROM xref GROUP BY xtype ORDER BY xtype')
  rows=cur.fetchall()
  for row in rows:
    outtxt+=('%18s: %8d\n'%(row[0],row[1]))

  return outtxt

#############################################################################
def TDLCounts(dbname,dbcon):
  cur=dbcon.cursor()
  sql='''\
SELECT tdl,COUNT(id)
FROM target
WHERE tdl in (%(TDLS)s)
GROUP BY tdl
'''%{'TDLS':"'"+("','".join(TDL.values()))+"'"}
  cur.execute(sql)
  rows=cur.fetchall()
  #outtxt=''
  rdata={}
  n_total=0
  for row in rows:
    #outtxt+=('%8s: %6d\n'%(row[0],row[1]))
    rdata[row[0]] = row[1]
    n_total+=row[1]
  rdata['total'] = n_total
  #outtxt+=('   Total: %6d\n'%(n_total))
  return rdata

#############################################################################
def ListXreftypes(dbname,dbcon,verbose=0):
  cur=dbcon.cursor(mysql.cursors.DictCursor)
  sql='SELECT DISTINCT xtype FROM xref ORDER BY xtype'
  cur.execute(sql)
  rows=cur.fetchall()
  xreftypes=[]
  for row in rows:
    if row.has_key('xtype'): xreftypes.append(row['xtype'])
  return xreftypes

#############################################################################
def ListXrefs(dbname,dbcon,qtype,fout,verbose):
  cur=dbcon.cursor(mysql.cursors.DictCursor)
  fout.write('"%s","target_id","protein_id"\n'%(qtype))
  cols=['value','target_id','protein_id']
  sql='''\
SELECT DISTINCT %(COLS)s
FROM xref
WHERE xtype = '%(QTYPE)s'
'''%{	'COLS':(','.join(cols)),
	'QTYPE':qtype }
  cur.execute(sql)
  row=cur.fetchone()
  n_xref=0;
  while row:
    tid = row['target_id'] if (row.has_key('target_id') and row['target_id']!=None) else ''
    pid = row['protein_id'] if (row.has_key('protein_id') and row['protein_id']!=None) else ''
    fout.write('"%s",%s,%s\n'%(row['value'],tid,pid))
    n_xref+=1
    row=cur.fetchone()
  print >>sys.stderr, 'Xrefs count: %d'%(n_xref)

#############################################################################
def ListTargets(dbname,dbcon,tdl,pfam,fout,verbose=0):
  cur=dbcon.cursor(mysql.cursors.DictCursor)
  cols=[
	'target.id',
	'target.fam',
	'target.name',
	'target.tdl',
	'target.ttype',
	'target.idg2',
	'protein.chr',
	'protein.description',
	'protein.family',
	'protein.geneid',
	'protein.id',
	'protein.name',
	'protein.sym',
	'protein.uniprot',
	'protein.up_version',
	'protein.stringid',
	'protein.dtoid'
	]
  fout.write('%s\n'%(','.join(cols)))
  sql='''
SELECT
	%(COLS)s
FROM
	target,
	protein,
	t2tc
'''%{'COLS':(','.join(map(lambda s: '%s AS %s'%(s,s.replace('.','_')),cols)))}
  wheres=['protein.id = t2tc.protein_id','target.id = t2tc.target_id']
  if tdl:
    wheres.append('target.tdl = \'%s\''%TDL[tdl])
  if pfam:
    wheres.append('target.fam = \'%s\''%pfam)
  if wheres:
    sql+=(' WHERE '+(' AND '.join(wheres)))
  #print >>sys.stderr, 'DEBUG: sql = "%s"'%sql
  
  cur.execute(sql)
  row=cur.fetchone()
  i_row=0;
  tids=set(); pids=set(); uniprots=set();
  colnames=map(lambda s: s.replace('.','_'),cols)
  while row:
    #print >>sys.stderr, 'DEBUG: %s'%str(row)
    #break #DEBUG
    i_row+=1
    if row.has_key('target_id'): tids.add(row['target_id'])
    if row.has_key('protein_id'): pids.add(row['protein_id'])
    if row.has_key('protein_uniprot'): uniprots.add(row['protein_uniprot'])
    for j,tag in enumerate(colnames):
      val = row[tag] if row.has_key(tag) else ''
      fout.write('%s"%s"'%((',' if j>0 else ''),val))
    fout.write('\n')
    row=cur.fetchone()
  print >>sys.stderr, 'TDL: %s'%(TDL[tdl] if tdl else 'all')
  #print >>sys.stderr, 'rows: %d'%(i_row)
  print >>sys.stderr, 'Target count: %d'%(len(tids))
  print >>sys.stderr, 'Protein count: %d'%(len(pids))
  print >>sys.stderr, 'Uniprot count: %d'%(len(uniprots))
  return

#############################################################################
def GetTargets(dbname,dbcon,qs,qtype,fout,verbose=0):
  '''Write data to CSV file, and return as list of dict-rows.'''
  if not qs:
    print >>sys.stderr, 'ERROR: no query ID.'
    return
  cur=dbcon.cursor(mysql.cursors.DictCursor)
  cols=[
	'target.description',
	'target.id',
	'target.fam',
	'target.name',
	'target.tdl',
	'target.ttype',
	'protein.chr',
	'protein.description',
	'protein.family',
	'protein.geneid',
	'protein.id',
	'protein.name',
	'protein.sym',
	'protein.uniprot'
	]
  if fout: fout.write('query,qtype,'+('%s\n'%(','.join(cols))))

  n_hit=0;
  tids_all=set();
  for qid in qs:
    sql='''\
SELECT
	%(COLS)s
FROM
	target
JOIN
	t2tc ON target.id = t2tc.target_id
JOIN
	protein ON protein.id = t2tc.protein_id
'''%{'COLS':(','.join(map(lambda s: '%s AS %s'%(s,s.replace('.','_')),cols)))}
    wheres=[]
    if qtype.lower()=='tid':
      wheres.append('target.id = %d'%int(qid))
    elif qtype.lower()=='uniprot':
      wheres.append('protein.uniprot = \'%s\''%qid)
    elif qtype.lower() in ('gid','geneid'):
      wheres.append('protein.geneid = \'%s\''%qid)
    elif qtype.lower() in ('genesymb','genesymbol'):
      wheres.append('protein.sym = \'%s\''%qid)
    elif qtype.lower() == 'ncbi_gi':
      sql+=('\nJOIN\n\txref ON xref.protein_id = protein.id')
      wheres.append('xref.xtype = \'NCBI GI\'')
      wheres.append('xref.value = \'%s\''%qid)
      wheres.append('xref.protein_id = protein.id')
    else:
      print >>sys.stderr, 'ERROR: unknown query type: %s'%qtype
      return
    sql+=(' WHERE '+(' AND '.join(wheres)))
    if verbose>2:
      print >>sys.stderr, 'DEBUG: "%s"'%sql
    if verbose>1:
      print >>sys.stderr, 'query: %s = "%s" ...'%(qtype,qid)
    cur.execute(sql)
    rows=cur.fetchall()
    if not rows:
      if verbose: print >>sys.stderr, 'Not found: %s = %s'%(qtype,qid)
      continue
    n_hit+=1
    tids_this=set();
    colnames=map(lambda s: s.replace('.','_'),cols)
    for row in rows:
      if row.has_key('target_id'): tids_this.add(row['target_id'])
      if fout: fout.write('"%s","%s"'%(qid,qtype))
      for j,tag in enumerate(colnames):
        val = row[tag] if row.has_key(tag) else ''
        if fout: fout.write(',"%s"'%(val))
      if fout: fout.write('\n')
    tids_all |= tids_this

  print >>sys.stderr, '%ss queries: %d, found: %d, not found: %d'%(qtype,len(qs),n_hit,(len(qs)-n_hit))
  print >>sys.stderr, 'Targets found: %d'%(len(tids_all))
  return list(tids_all)

#############################################################################
def GetPathways(dbname,dbcon,tids,fout,verbose):
  cur=dbcon.cursor(mysql.cursors.DictCursor)
  cols=[
	't2p.target_id',
	't2p.id',
	't2p.source',
	't2p.id_in_source',
	't2p.name',
	't2p.description',
	't2p.url'
	]
  if fout: fout.write('%s\n'%(','.join(cols)))

  n_hit=0;
  pids_all=set();
  for tid in tids:
    sql='''\
SELECT
	%(COLS)s
FROM
	target2pathway t2p
JOIN
	target t ON t.id = t2p.target_id
WHERE
	t.id = %(TID)s
ORDER BY
	t2p.target_id,
	t2p.id
'''%{	'COLS':(','.join(map(lambda s: '%s AS %s'%(s,s.replace('.','_')),cols))),
	'TID':str(tid)
	}

    if verbose>2:
      print >>sys.stderr, 'DEBUG: "%s"'%sql
    if verbose>1:
      print >>sys.stderr, 'query: %s ...'%(tid)
    cur.execute(sql)
    rows=cur.fetchall()
    if not rows:
      if verbose: print >>sys.stderr, 'Not found: %s'%(str(tid))
      continue
    n_hit+=1
    pids_this=set();
    colnames=map(lambda s: s.replace('.','_'),cols)
    for row in rows:
      if row.has_key('id'): pids_this.add(row['id'])
      for j,tag in enumerate(colnames):
        val = row[tag] if row.has_key(tag) else ''
        #if type(val) in types.StringTypes: val = val.decode('unicode-escape')
        if type(val) in types.StringTypes: val = val.encode('string-escape')
        if fout: fout.write(',"%s"'%(val))
      if fout: fout.write('\n')
    pids_all |= pids_this

  print >>sys.stderr, 'queries: %d, found: %d, not found: %d'%(len(tids),n_hit,(len(tids)-n_hit))
  print >>sys.stderr, 'Pathways found: %d'%(len(pids_all))
  return list(pids_all)

#############################################################################
if __name__=='__main__':

  usage='''
  %(PROG)s - TCRD db client utility (see also REST API client)

operations:
  --info .............. db info
  --describe .......... describe db schema
  --counts ............ table row counts
  --tdl_counts ........ target development level counts
  --xref_counts ....... synonyms, aliases and xrefs
  --attr_counts ....... attributes
  --list_targets ...... list targets, optionally for specified TDL
  --get_targets ....... get targets for query name, ID
  --get_targetpathways ... get pathways for specified targets
  --list_xref_types ... list xref types
  --list_xrefs ........ list xrefs for specified xref type

query:
  --query QID ......... query ID or symbol
  --qfile QFILE ....... input query file
  --qtype QTYPE ....... TID|GENEID|UNIPROT|GENESYMB

  query types:
    TID .............. TCRD target ID (e.g. 1, 2, 3)
    GENEID ........... NCBI Entrez gene ID (e.g. 7529,10971)
    UNIPROT .......... Uniprot ID (e.g. Q04917,P04439)
    GENESYMB ......... HUGO gene symbol (e.g. GPER1, HLA-A,YWHAG)
    NCBI_GI .......... NCBI GI numbers

parameters:
  --tdl TDL ........... TDL [0-4] %(TDL)s
  --fam FAM ........... GPCR|Kinase|IC|NR|...|Unknown

options:
  --o OFILE ........... output file (CSV)
  --dbname DBNAME ..... [%(DBNAME)s]
  --dbhost DBHOST ..... [%(DBHOST)s]
  --dbusr DBUSR ....... [%(DBUSR)s]
  --dbpw DBPW .........
  --v[v[v]] ........... verbose [very [very]]
  --h ................. this help

'''%{'PROG':PROG,'DBNAME':DBNAME,'DBHOST':DBHOST,'DBUSR':DBUSR,
	'TDL':str(TDL)}

  def ErrorExit(msg):
    print >>sys.stderr,msg
    sys.exit(1)

  ofile=None;
  qfile=None;
  query=None;
  verbose=0;
  describe=False;
  info=False;
  counts=False;
  tdl_counts=False;
  xref_counts=False;
  attr_counts=False;
  list_targets=False;
  list_xref_types=False;
  list_xrefs=False;
  get_targets=False;
  get_targetpathways=False;
  tdl=None;
  fam=None;

  query=None;
  qtype='TID';

  test=False;
  opts,pargs = getopt.getopt(sys.argv[1:],'',['h','v','vv','vvv',
	'o=',
	'query=', 'qfile=', 'qtype=',
	'tdl=', 'fam=',
	'info', 'describe', 'counts', 'tdl_counts', 'xref_counts', 'attr_counts',
	'list_targets',
	'list_xref_types',
	'list_xrefs',
	'get_targets',
	'get_targetpathways',
	'dbname=', 'dbhost=', 'dbusr=', 'dbpw=' ])
  if not opts: ErrorExit(usage)
  for (opt,val) in opts:
    if opt=='--h': ErrorExit(usage)
    elif opt=='--o': ofile=val
    elif opt=='--qfile': qfile=val
    elif opt=='--query': query=val
    elif opt=='--qtype': qtype=val
    elif opt=='--info': info=True
    elif opt=='--describe': describe=True
    elif opt=='--counts': counts=True
    elif opt=='--tdl_counts': tdl_counts=True
    elif opt=='--xref_counts': xref_counts=True
    elif opt=='--attr_counts': attr_counts=True
    elif opt=='--list_targets': list_targets=True
    elif opt=='--list_xref_types': list_xref_types=True
    elif opt=='--list_xrefs': list_xrefs=True
    elif opt=='--get_targets': get_targets=True
    elif opt=='--get_targetpathways': get_targetpathways=True
    elif opt=='--tdl': tdl=int(val)
    elif opt=='--fam': fam=val
    elif opt=='--dbname': DBNAME=val
    elif opt=='--dbhost': DBHOST=val
    elif opt=='--dbusr': DBUSR=val
    elif opt=='--dbpw': DBPW=val
    elif opt=='--v': verbose=1
    elif opt=='--vv': verbose=2
    elif opt=='--vvv': verbose=3
    else: ErrorExit('Illegal option: %s'%val)

  if ofile:
    fout=open(ofile,"w+")
    #fout=codecs.open(ofile,"w","utf8","replace")
    if not fout: ErrorExit('ERROR: cannot open outfile: %s'%ofile)
  else:
    fout=sys.stdout
    #fout=codecs.getwriter('utf8')(sys.stdout,errors="replace")

  qs=[]
  if qfile:
    fin=open(qfile)
    if not fin: ErrorExit('ERROR: cannot open qfile: %s'%qfile)
    while True:
      line=fin.readline()
      if not line: break
      try:
        qs.append(line.rstrip())
      except:
        print >>sys.stderr, 'ERROR: bad input ID: %s'%line
        continue
    if verbose:
      print >>sys.stderr, '%s: input IDs: %d'%(PROG,len(qs))
    fin.close()
  elif query:
    qs.append(query)

  dbcon = Connect(dbhost=DBHOST,dbname=DBNAME,dbusr=DBUSR,dbpw=DBPW)

  if describe:
    print Describe(DBNAME,dbcon)

  elif info:
    rdata = Info(DBNAME,dbcon)
    print json.dumps(rdata,indent=2,sort_keys=True)

  elif counts:
    print Counts(DBNAME,dbcon)

  elif xref_counts:
    print XrefCounts(DBNAME,dbcon)

  elif attr_counts:
    print AttributeCounts(DBNAME,dbcon)

  elif tdl_counts:
    rdata = TDLCounts(DBNAME,dbcon)
    print json.dumps(rdata,indent=2,sort_keys=True)

  elif list_targets:
    ListTargets(DBNAME,dbcon,tdl,fam,fout,verbose)

  elif get_targets:
    GetTargets(DBNAME,dbcon,qs,qtype,fout,verbose)

  elif get_targetpathways:
    tids = GetTargets(DBNAME,dbcon,qs,qtype,None,verbose)
    GetPathways(DBNAME,dbcon,tids,fout,verbose)

  elif list_xref_types:
    xreftypes = ListXreftypes(DBNAME,dbcon,verbose)
    print str(xreftypes)

  elif list_xrefs:
    xreftypes = ListXreftypes(DBNAME,dbcon,verbose)
    if qtype not in xreftypes:
      ErrorExit('ERROR: qtype "%s" invalid.  Available xref types: %s'%(qtype,str(xreftypes)))
    ListXrefs(DBNAME,dbcon,qtype,fout,verbose)

  else:
    ErrorExit('ERROR: No operation specified.')

  dbcon.close()
