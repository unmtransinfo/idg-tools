--
SELECT
	t.id AS "tid",
	t.name,
	t.ttype,
	t.description,
	t.comment,
	t.tdl,
	t.idg,
	t.fam,
	t.famext,
        p.id AS "pid",
        p.uniprot,
        p.geneid,
        p.sym
FROM
	target t,
	t2tc,
	protein p
WHERE
	t.id = t2tc.target_id
	AND t2tc.protein_id = p.id
        AND p.geneid IS NOT NULL
        AND p.sym IS NOT NULL
	AND t.idg > 0
	;
--
