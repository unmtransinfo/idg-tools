SELECT
        ppitype,
        interaction_type,
        evidence,
        COUNT(id)
FROM 
        ppi
GROUP BY 
        ppitype, interaction_type, evidence
;