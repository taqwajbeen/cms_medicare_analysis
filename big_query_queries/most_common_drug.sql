--- MOST COMMON DRUG PRESCRIBED IN EACH STATE
WITH DRUG_COUNT AS
(SELECT generic_name, nppes_provider_state, count (*) total_prescribled 
FROM `bigquery-public-data.cms_medicare.part_d_prescriber_2014`
GROUP BY 1,2
ORDER BY 3 DESC ),

MOST_COMMON AS (

SELECT*,

rank () OVER (PARTITION BY  nppes_provider_state ORDER BY  
total_prescribled desc) rnk

FROM DRUG_COUNT)

SELECT generic_name DRUG_NAME, nppes_provider_state STATE, 
total_prescribled TOTAL_PRESCRIBLED FROM MOST_COMMON 
WHERE
rnk =1

