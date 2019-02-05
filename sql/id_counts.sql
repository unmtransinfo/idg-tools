--
SELECT type, COUNT(DISTINCT id) AS alias_count FROM alias GROUP BY type ORDER BY type ;
--
SELECT xtype, COUNT(DISTINCT value) AS xref_count FROM xref  GROUP BY xtype ORDER BY xtype ;
--
SELECT ttype, COUNT(DISTINCT id) AS target_count FROM target GROUP BY ttype ORDER BY ttype ;
--
SELECT xtype, COUNT(DISTINCT value) AS xref_count FROM xref GROUP BY xtype ORDER BY xtype ;
--
SELECT dtype, COUNT(DISTINCT did) AS disease_count FROM disease GROUP BY dtype ORDER BY dtype ;
--
SELECT pwtype, COUNT(DISTINCT id) AS pathway_count FROM pathway GROUP BY pwtype ORDER BY pwtype ;
--
SELECT ptype, COUNT(DISTINCT id) AS phenotype_count FROM phenotype GROUP BY ptype ORDER BY ptype ;
--
