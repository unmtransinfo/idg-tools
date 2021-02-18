SELECT
        d.dtype,
        dt.description dtype_description,
        d.name,
        d.ncats_name,
        d.did,
        d.description,
        d.reference,
        d.drug_name,
        d.source,
        COUNT(d.protein_id) n_target_associations
FROM
        disease d
        JOIN disease_type dt ON dt.name = d.dtype
GROUP BY
        d.dtype,
        dt.description,
        d.name,
        d.ncats_name,
        d.did,
        d.description,
        d.reference,
        d.drug_name,
        d.source
ORDER BY
        name
;