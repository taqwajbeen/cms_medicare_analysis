--- OUT/IN PATIENT PAYMENTS IN EACH STATE
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

