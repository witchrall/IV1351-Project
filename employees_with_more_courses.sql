/*view 4*/
CREATE VIEW employees_with_more_courses AS 
WITH  multiple_courses AS(
SELECT 
	  emp.employment_id AS "Employment ID",
	  CONCAT(per.first_name, ' ', per.last_name) AS "Teachers Name",
	  ci.study_period AS "Period",
	  COUNT(DISTINCT ci.instance_id) AS "No of Course"

FROM course_instance AS ci
JOIN course_layout AS cl ON ci.course_layout_id = cl.course_layout_id 
JOIN course_credits AS cc ON cc.course_layout_id = ci.course_layout_id 
AND cc.study_period = ci.study_period
JOIN activity_allocation AS aa ON aa.instance_id = ci.instance_id 
JOIN planned_activity AS pa ON ci.instance_id = pa.instance_id AND aa.activity_name = pa.activity_name
JOIN teaching_activity AS ta ON ta.activity_name = pa.activity_name
JOIN employee AS emp ON aa.employment_id = emp.employment_id
JOIN person as per ON emp.person_id = per.person_id
WHERE EXTRACT(YEAR FROM ci.start_date) = EXTRACT(YEAR FROM CURRENT_DATE) AND ci.study_period :: text = ( 'P' || (((EXTRACT(MONTH FROM CURRENT_DATE)::int - 1)/3) + 1))::text
GROUP BY "Employment ID", "Teachers Name", "Period"
)

SELECT
    "Employment ID",
	"Teachers Name",
	"Period",
	"No of Course"
FROM multiple_courses
ORDER BY "Employment ID";