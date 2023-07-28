--- TOP 3 most common outpatient diagnosis from 2011-2015 across USA
WITH CTE AS (
SELECT *, '2011' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2011` UNION ALL
SELECT * ,'2012' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2012` UNION ALL
SELECT *, '2013' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2013` UNION ALL
SELECT *, '2014' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2014` UNION ALL
SELECT *, '2015' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2015`
),
CTE1 AS (
SELECT  drg_definition, year,
SUM (average_total_payments) OVER (PARTITION BY CTE.drg_definition, year 
ORDER BY year) total_payment
FROM CTE),
CTE2 AS ( SELECT *,
rank () OVER (PARTITION BY year
ORDER BY total_payment desc) rnk
FROM CTE1)
SELECT SUBSTR(drg_definition, 6) diagnoses, year, cast (total_payment AS 
numeric) total_payment FROM CTE2
WHERE rnk BETWEEN 1 AND 3 ORDER BY  year, rnk
LIMIT 20;

