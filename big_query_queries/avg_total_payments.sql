--- Average total payemnts for top 10 hospital between 2011 and 2015
SELECT hospital_name,sum(average_total_payments) AS total 
FROM `bigquery-public-data.cms_medicare.hospital_general_info` AS hgi
JOIN `bigquery-public-data.cms_medicare.inpatient_charges*` AS ic
ON hgi.provider_id=ic.provider_id
GROUP BY 1
ORDER BY TOTAL DESC
LIMIT 10
