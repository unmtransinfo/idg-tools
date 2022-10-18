SELECT DISTINCT
SUBSTR(did, 1, INSTR(did, ':'))
FROM disease
-- WHERE dtype = 'CTD'
-- WHERE dtype = 'DisGeNET'
-- WHERE dtype = 'DrugCentral indication'
-- WHERE dtype = 'Expression Atlas'
-- WHERE dtype LIKE 'JensenLab Experiment%'
-- WHERE dtype LIKE 'JensenLab Knowledge%'
-- WHERE dtype LIKE 'JensenLab Text Mining%'
-- WHERE dtype = 'Monarch'
WHERE dtype = 'UniProt Disease'
-- WHERE dtype = 'eRAM'
;