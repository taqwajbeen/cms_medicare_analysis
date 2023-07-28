--- Average total payemnts for top 10 hospital between 2011 and 2015
SELECT hospital_name,sum(average_total_payments) AS total 
FROM `bigquery-public-data.cms_medicare.hospital_general_info` AS hgi
JOIN `bigquery-public-data.cms_medicare.inpatient_charges*` AS ic
ON hgi.provider_id=ic.provider_id
GROUP BY 1
ORDER BY TOTAL DESC
LIMIT 10

—-HOSPITAL RATINGS COMPARED WITH NATIONAL AVERAGE
WITH CTE AS
(SELECT hospital_name, hospital_overall_rating
FROM `bigquery-public-data.cms_medicare.hospital_general_info`
WHERE state = 'WI' AND hospital_overall_rating <>'Not Available'),
C1 AS
(SELECT ROUND(AVG(CAST (hospital_overall_rating AS int64)),2) AS 
US_AVG_HOSPITAL_RATING
FROM `bigquery-public-data.cms_medicare.hospital_general_info`
WHERE hospital_overall_rating <>'Not Available')
SELECT *
FROM CTE
WHERE cast(hospital_overall_rating as NUMERIC)> (SELECT* FROM C1) 


— AVG STATE RATING  BETTER THAN NATIONAL AVG
WITH CTE AS
(SELECT state,ROUND(avg( cast ( hospital_overall_rating as int64)),2) 
STATE_AVG_RATING 
From `bigquery-public-data.cms_medicare.hospital_general_info`
WHERE hospital_overall_rating <>'Not Available'
GROUP BY 1),
CTE1 AS
(SELECT ROUND (AVG (CAST (hospital_overall_rating AS int64)) ,2) AS 
US_AVG_HOSPITAL_RATING
FROM`bigquery-public-data.cms_medicare.hospital_general_info`
WHERE hospital_overall_rating <> 'Not Available')
SELECT * FROM CTE
WHERE STATE_AVG_RATING > (SELECT * FROM CTE1) 



— OUT/IN PATIENT PAYMENTS IN EACH STATE
WITH outpatient AS (
SELECT * ,'2011' as year from 
`bigquery-public-data.cms_medicare.outpatient_charges_2011`  UNION ALL 
SELECT *, '2012' as year from 
`bigquery-public-data.cms_medicare.outpatient_charges_2012`  UNION ALL 
SELECT * ,'2013' as year from 
`bigquery-public-data.cms_medicare.outpatient_charges_2013`  UNION ALL 
SELECT *, '2014' as year from 
`bigquery-public-data.cms_medicare.outpatient_charges_2014`  UNION ALL
SELECT provider_id, provider_name, provider_street_address, provider_city, 
provider_state, cast (provider_zipcode as string) provider_zipcode, apc, 
hospital_referral_region,outpatient_services, 
average_estimated_submitted_charges, average_total_payments, '2015' as 
year from `bigquery-public-data.cms_medicare.outpatient_charges_2015` ),
inpatient AS (
SELECT *, '2011' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2011`  UNION ALL 
SELECT * ,'2012' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2012`  UNION ALL 
SELECT *, '2013' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2013`  UNION ALL 
SELECT *, '2014' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2014`  UNION ALL 
SELECT *, '2015' as year from 
`bigquery-public-data.cms_medicare.inpatient_charges_2015` 
)
SELECT inpatient.provider_state provider_state, ROUND (avg 
(outpatient.average_total_payments) ,2) AVG_TOTAL_PAYMENTS_OUTPATIENT,
ROUND (avg (inpatient.average_total_payments),2) 
AVG_TOTAL_PAYMENTS_INPATIENT
FROM outpatient
JOIN inpatient
ON outpatient.provider_id = inpatient.provider_id
GROUP BY 1


— MOST COMMON DRUG PRESCRIBED IN EACH STATE
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


—-TOP 3 most common outpatient diagnosis from 2011-2015 across USA
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
