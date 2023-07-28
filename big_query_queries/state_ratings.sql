
--- AVG STATE RATING  BETTER THAN NATIONAL AVG
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

