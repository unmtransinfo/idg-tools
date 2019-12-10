#!/usr/bin/env python3
"""
	http://igraph.org/python/doc/tutorial/tutorial.html

	Note that igraph defines its own IDs.  These are integers, not the same
	as imported GraphML "id" values.

	See also: igraph_plot.py
"""
#############################################################################
import sys,os,argparse
import re,random,tempfile,shutil
import json
import igraph


#############################################################################
def Load_GraphML(ifile, verbose):
  g = igraph.Graph.Read_GraphML(ifile)
  if verbose:
    print('\tnodes: %d ; edges: %d'%(g.vcount(),g.ecount()), file=sys.stderr)
  return g

#############################################################################
def GraphSummary(g, verbose):
  #igraph.summary(g,verbosity=0) ## verbosity=1 prints edge list!

  name = g['name'] if 'name' in g.attributes() else None
  print('graph name: "%s"'%(name), file=sys.stderr)
  print('\t                 nodes: %3d'%(g.vcount()), file=sys.stderr)
  print('\t                 edges: %3d'%(g.ecount()), file=sys.stderr)
  print('\t             connected: %s'%(g.is_connected(mode=igraph.WEAK)), file=sys.stderr)
  print('\t            components: %3d'%(len(g.components(mode=igraph.WEAK))), file=sys.stderr)
  print('\t              directed: %s'%(g.is_directed()), file=sys.stderr)
  print('\tDAG (directed-acyclic): %s'%(g.is_dag()), file=sys.stderr)
  print('\t              weighted: %s'%(g.is_weighted()), file=sys.stderr)
  print('\t              diameter: %3d'%(g.diameter()), file=sys.stderr)
  print('\t                radius: %3d'%(g.radius()), file=sys.stderr)
  print('\t             maxdegree: %3d'%(g.maxdegree()),file=sys.stderr)

#############################################################################
def XOR(a,b): return ((a and not b) or (b and not a))

#############################################################################
def NodeSelect_String(g,selectfield,selectquery,exact,negate,verbose):
  vs=[]
  if exact:
    vs = eval('g.vs.select(%s_%s = "%s")'%(selectfield,('ne' if negate else 'eq'),selectquery))
  else:
    for v in g.vs:
      if XOR(re.search(selectquery,v[selectfield],re.I),negate):
        vs.append(v)
  return vs

#############################################################################
def ConnectedNodes(g,verbose):
  vs=[]
  for v in g.vs:
    #if g.neighbors(v, igraph.ALL):
    if v.degree()>0:
      vs.append(v)
  return vs

#############################################################################
def DisconnectedNodes(g,verbose):
  vs=[]
  for v in g.vs:
    #if not g.neighbors(v, igraph.ALL):
    if v.degree()==0:
      vs.append(v)
  return vs

#############################################################################
def RootNodes(g):
  '''In a directed graph, which are the root nodes?'''
  if not g.is_directed():
    print('ERROR: graph not directed; cannot have root nodes.', file=sys.stderr)
  if not g.is_dag():
    print('ERROR: graph not directed-acyclic; cannot have proper root nodes.', file=sys.stderr)
  vs=[]
  for v in g.vs:
    #if not g.neighbors(v, igraph.IN):
    #if g.indegree(v)==0:
    if v.indegree()==0:
      vs.append(v)
  return vs

#############################################################################
def AddChildren(vs,r,depth,ntype):
  if depth<=0: return
  for c in r.neighbors(ntype):
    vs.append(c)
    AddChildren(vs,c,depth-1,ntype)

#############################################################################
def TopNodes(g,depth):
  vs = []
  rs = RootNodes(g)
  vs.extend(rs)
  for r in rs:
    PrintHierarchy(r,depth,0)
    AddChildren(vs,r,depth,igraph.OUT)
  return vs

#############################################################################
def PrintHierarchy(n,depth,i):
  if i>depth: return
  print('%s%s: %s'%(('\t'*i),n['id'],n['name']))
  for c in n.neighbors(igraph.OUT):
    PrintHierarchy(c,depth,i+1)


#############################################################################
def DegreeDistribution(g,verbose):
  dd = g.degree_distribution(bin_width=1,mode=igraph.ALL,loops=True)
  print('%s'%dd, file=sys.stderr)

#############################################################################
def ShortestPath(g,nidA,nidB,verbose):
  '''Must use GraphBase (not Graph) method to get path data.'''

  vA = g.vs.find(id = nidA)
  vB = g.vs.find(id = nidB)
  paths = g.get_shortest_paths(vA, [vB], weights=None, mode=igraph.ALL, output="vpath")

  for path in paths:
    print('DEBUG: path = %s'%str(path))
    n_v=len(path)
    for j in range(n_v):
      vid=path[j]
      v = g.vs[vid]
      dr=None
      if j+1<n_v:
        vid_next = path[j+1]
        edge = g.es.find(_between = ([vid], [vid_next]))
        dr = 'FROM' if edge.source==vid else 'TO'
        #print('DEBUG: edge: %s %s %s'%(g.vs[edge.source]['doid'], dr, g.vs[edge.target]['doid']))
      print('DEBUG: %d. %s (%s)%s'%(j+1,v['doid'], v['name'],(' %s...'%dr if dr else '')))
    vid_pa = PathRoot(g,path,verbose)
    print('DEBUG: path ancestor: %s'%g.vs[vid_pa]['doid'])

#############################################################################
def PathRoot(g, path, verbose):
  '''Given a DAG path (NIDs), return NID for root, i.e. node with no target.'''
  n_v=len(path)
  for j in range(n_v):
    vid=path[j]
    if j+1<n_v:
      vid_next = path[j+1]
      edge = g.es.find(_between = ([vid], [vid_next]))
      if edge.source==vid:
        return vid
    else:
      return vid
  return None

#############################################################################
def GetAncestors(g,vidxA):
  vA = g.vs[vidxA]
  vidxAncestors = {}
  for p in vA.neighbors(igraph.IN):
    vidxAncestors[p.index] = True
    vidxAncestors.update(GetAncestors(g,p.index))
  return vidxAncestors

#############################################################################
def ShowAncestry(g,vidxA,level,verbose):
  vA = g.vs[vidxA]
  print('%2s %6s [%6s] %-14s (%s)'%(('-%d'%level if level else ''),
	('^'*level), vA.index, vA['id'], vA['name']), file=sys.stderr)
  for p in vA.neighbors(igraph.IN):
    ShowAncestry(g,p.index,level+1,verbose)

#############################################################################
### GraphBase.bfs():
### Returns tuple:
###     The vertex IDs visited (in order)
###     The start indices of the layers in the vertex list
###     The parent of every vertex in the BFS
#############################################################################
#def BreadthFirstSearchTest(g, verbose):
#  rs = igraph_utils.RootNodes(g)
#  if len(rs)>1:
#    print('WARNING: multiple root nodes (%d) using one only.'%len(rs),
#    file=sys.stderr)
#  r = rs[0];
#  bfs = g.bfs(r.index, mode=igraph.OUT)
#  vids, start_idxs, prnts = bfs
#  print('DEBUG: len(vids) = %d; len(start_idxs) = %d; len(prnts) = %d'%(len(vids),len(start_idxs), len(prnts)), file=sys.stderr)
#
#  print('layers: %d'%(len(start_idxs)), file=sys.stderr)
#  start_idx_prev=0;
#  for layer,start_idx in enumerate(start_idxs):
#    print('layer = %d'%(layer), file=sys.stderr)
#    for i in range(start_idx_prev,start_idx):
#      print('\t%d) vs[%d]: %s (%s); parent = %s (%s)'%(layer, vids[i],
#       g.vs[vids[i]]['id'], g.vs[vids[i]]['name'],
#       g.vs[prnts[vids[i]]]['id'], g.vs[prnts[vids[i]]]['name']),
#       file=sys.stderr)
#    start_idx_prev=start_idx

#############################################################################
def DisplayGraph(g,layout,w,h,verbose):
  '''Layouts:
 "rt"          : reingold tilford tree
 "rt_circular" : reingold tilford circular
 "fr"          : fruchterman reingold
 "lgl"         : large_graph
'''
  visual_style = {}
  #color_dict = {"m": "blue", "f": "pink"}
  #for v in g.vs:
  #  v["gender"] = random.choice(('m','f'))
  #for e in g.es:
  #  e["is_formal"] = random.choice(range(0,3))
  if layout=='kk':
    visual_style["layout"] = g.layout('kk')
  elif layout=='rt':
    visual_style["layout"] = g.layout('rt',3) #tree depth?
  else:
    visual_style["layout"] = g.layout('large')

  visual_style["bbox"] = (w, h)
  visual_style["vertex_label"] = g.vs["name"]
  visual_style["vertex_size"] = 25
  #visual_style["vertex_size"] = [25+random.choice(range(-10,10)) for v in g.vs]
  visual_style["vertex_color"] = "lightblue"
  #visual_style["vertex_color"] = [color_dict[gender] for gender in g.vs["gender"]]
  visual_style["vertex_shape"] = [random.choice(('rect','circle','rhombus')) for v in g.vs]
  #visual_style["edge_width"] = [1 + 2 * int(is_formal) for is_formal in g.es["is_formal"]]
  visual_style["edge_width"] = 2
  visual_style["margin"] = 20
  igraph.plot(g, **visual_style)

#############################################################################
def Graph2CyJsElements(g):
  '''Convert igraph object to CytoscapeJS-compatible JSON "elements".'''
  def merge_dicts(x,y):
    #return x.copy().update(y) #Python2
    return {**x, **y} #Python3
  nodes = []
  for v in g.vs:
    nodes.append({'data':merge_dicts({'id':v['id']}, v.attributes())})
  edges = []
  for e in g.es:
    v_source = g.vs[e.source]
    v_target = g.vs[e.target]
    edges.append({'data':merge_dicts({'source':v_source['id'], 'target':v_target['id']}, e.attributes())})
  for node in nodes:
    if 'class' in node['data']:
      node['classes'] = node['data']['class']
  CyGraph = nodes + edges
  CyGraphJS = json.dumps(CyGraph, indent=2, sort_keys=False)
  return CyGraphJS

#############################################################################
def VisualStyle(g):
  for v in g.vs:
    v["gender"] = random.choice(('m','f'))
  for e in g.es:
    e["is_formal"] = random.choice(range(0,3))
  visual_style = {}
  #visual_style["vertex_size"] = 25
  visual_style["vertex_size"] = [25+random.choice(range(-10,10)) for v in g.vs]
  color_dict = {"m": "blue", "f": "pink"}
  visual_style["vertex_color"] = [color_dict[gender] for gender in g.vs["gender"]]
  visual_style["vertex_shape"] = [random.choice(('rect','circle','rhombus')) for v in g.vs]
  visual_style["vertex_label"] = g.vs["name"]
  visual_style["edge_width"] = [1 + 2 * int(is_formal) for is_formal in g.es["is_formal"]]
  visual_style["bbox"] = (700, 500)
  visual_style["margin"] = 20

  return visual_style

#############################################################################
def Plot(g, ofile_plot):
  vstyle = VisualStyle(g)
  if ofile_plot:
    igraph.plot(g, ofile_plot, **vstyle)
  else:
    igraph.plot(g, **vstyle) #interactive

#############################################################################
def Layout(g, method):
  if method=='kamada_kawai':
    visual_style["layout"] = g.layout("kk")
  elif method=='reingold_tilford':
    visual_style["layout"] = g.layout("rt",2)
  elif method=='reingold_tilford_circular':
    visual_style["layout"] = g.layout("rt_circular")
  elif method=='fruchterman_reingold':
    visual_style["layout"] = g.layout("fr")
  elif method=='large_graph':
    visual_style["layout"] = g.layout("lgl")

#############################################################################
if __name__=='__main__':
  PROG=os.path.basename(sys.argv[0])
  DEPTH=1;

  parser = argparse.ArgumentParser(description='IGraph (python-igraph API) utility, graph processingand display')
  ops = ['summary',
	'degree_distribution',
	'rootnodes',
	'topnodes',
  	'graph2cyjs',
	'shortest_path',
	'show_ancestry',
	'connectednodes',
	'disconnectednodes',
	'node_select',
	'edge_select' ]
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--i", dest="ifile", help="input file or URL (e.g. GraphML)")
  parser.add_argument("--o", dest="ofile", help="output file")
  parser.add_argument("--selectfield", help="field (attribute) to select")
  parser.add_argument("--selectquery", help="string query")
  parser.add_argument("--selectval", type=float, help="numerical query")
  parser.add_argument("--select_exact", help="exact string match (else substring/regex)")
  parser.add_argument("--select_equal", action="store_true", help="numerical equality select")
  parser.add_argument("--select_lt", action="store_true", help="numerical less-than select")
  parser.add_argument("--select_gt", action="store_true", help="numerical greater-than select")
  parser.add_argument("--select_negate", action="store_true", help="negate select criteria")
  parser.add_argument("--display", help="display graph interactively")
  parser.add_argument("--depth", type=int, default=DEPTH, help="depth for --topnodes")
  parser.add_argument("--nidA", help="nodeA ID")
  parser.add_argument("--nidB", help="nodeB ID")
  parser.add_argument("-v", "--verbose", dest="verbose", action="count", default=0)
  args = parser.parse_args()

  if args.ifile:
    fin=open(args.ifile)
    if not fin: parser.error('ERROR: cannot open: %s'%args.ofile)
  else:
    parser.error('ERROR: --i required.')

  if args.ofile:
    fout=open(args.ofile,"w+")
    if not fout: parser.error('ERROR: cannot open: %s'%args.ofile)
  else:
    fout=sys.stdout

  epilog='''\
operations:
        --summary ................... summary of graph
        --degree_distribution ....... degree distribution
        --node_select ............... select for nodes by criteria
        --edge_select ............... select for edges by criteria
	--connectednodes ............ connected node[s]
	--disconnectednodes ......... disconnected node[s]
	--rootnodes ................. root node[s] of DAG
	--topnodes .................. root node[s] & children of DAG
	--shortest_paths ............ shortest paths, nodes A ~ B
	--show_ancestry ............. show ancestry, node A
	--graph2cyjs ................ CytoscapeJS JSON

Note: select also deletes non-matching for modified output.

'''

  ###
  #INPUT:
  ###
  g = Load_GraphML(args.ifile, args.verbose)

  vs = []; #vertices for subgraph selection

  if args.op=='summary':
    GraphSummary(g, args.verbose)

  elif args.op=='degree_distribution':
    DegreeDistribution(g, args.verbose)

  elif args.op=='node_select':
    if args.selectquery:
      vs = NodeSelect_String(g, args.selectfield, args.selectquery,
args.select_exact, args.select_negate, args.verbose)
    elif args.selectval:
      parser.error('ERROR: numerical select not implemented yet.')
    else:
      parser.error('ERROR: select query or value required.')

  elif args.op=='edge_select':
    parser.error('ERROR: not implemented yet.')

  elif args.op=='connectednodes':
    vs = ConnectedNodes(g, args.verbose)

  elif args.op=='disconnectednodes':
    vs = DisconnectedNodes(g, args.verbose)

  elif args.op=='rootnodes':
    vs = RootNodes(g)

  elif args.op=='topnodes':
    vs = TopNodes(g, args.depth)

  elif args.op=='shortest_path':
    if not ( args.nidA and  args.nidB): parser.error('ERROR: --shortest_path requires nidA and nidB.')
    vs = ShortestPath(g, args.nidA, args.nidB, args.verbose)

  elif args.op=='show_ancestry':
    if not nidA: parser.error('ERROR: --show_ancestry requires nidA.')
    vA = g.vs.find(id =  args.nidA)
    vidxA = vA.index
    ShowAncestry(g, vidxA, 0, args.verbose)

  elif args.op=='graph2cyjs':
    print(Graph2CyJsElements(g))


  if vs:
    #if verbose>1:
    #  for v in vs:
    #    print('%s: %s'%(v['id'],v['name']))
    print('selected nodes: %d'%len(vs), file=sys.stderr)
    g = g.induced_subgraph(vs, implementation="auto")
    print('SELECTED SUBGRAPH:  nodes: %d ; edges: %d'%(g.vcount(),g.ecount()), file=sys.stderr)

  ###
  #OUTPUT:
  ###
  if args.ofile:
    g.write_graphml(fout) #Works but maybe changes tags?
    fout.close()

  elif display:
    w,h = 700,500
    layout = 'rt'
    DisplayGraph(g, layout, w, h, verbose)

