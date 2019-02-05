-- DTO classes:
-- Hierarchy: Class::Group::Family::Ligand Type
-- 
SELECT DISTINCT
	dto.name, dto.value
FROM
	dto_classification dto
WHERE
	dto.name IN ('GPCR Class', 'IC Family', 'Kinase Type', 'NR Family')
ORDER BY dto.name, dto.value ;
--
SELECT
	dto.name,
	COUNT(DISTINCT dto.id)
FROM
	dto_classification dto
GROUP BY
	dto.name
ORDER BY
	dto.name
	;
--
