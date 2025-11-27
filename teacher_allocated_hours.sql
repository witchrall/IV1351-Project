/*SEM2 view3 */
CREATE VIEW teacher_allocated_hours AS 
WITH teacher_allocation AS (
SELECT 
	cl.course_code AS "Course Code",
	ci.instance_id AS "Course Instance ID",
	cc.hp AS "HP",
	ci.study_period AS "Period",
	CONCAT(per.first_name, ' ' , per.last_name) AS "Teacher's Name",
	SUM(CASE WHEN pa.activity_name = 'Lecture'
	         THEN pa.planned_hours * ta.factor ELSE 0 END) AS "Lecture Hours",
	SUM(CASE WHEN pa.activity_name = 'Tutorial'
	         THEN pa.planned_hours * ta.factor ELSE 0 END) AS "Tutorial Hours",
	SUM(CASE WHEN pa.activity_name = 'Lab'
	         THEN pa.planned_hours * ta.factor ELSE 0 END) AS "Lab Hours",
	SUM(CASE WHEN pa.activity_name = 'Seminar'
	         THEN pa.planned_hours * ta.factor ELSE 0 END) AS "Seminar Hours",
	SUM(CASE WHEN pa.activity_name = 'Administration'
	         THEN pa.planned_hours * ta.factor ELSE 0 END) AS "Admin",
	SUM(CASE WHEN pa.activity_name = 'Examination'
	         THEN pa.planned_hours * ta.factor ELSE 0 END) AS "Exam"


FROM course_instance AS ci
JOIN course_layout AS cl ON ci.course_layout_id = cl.course_layout_id 
JOIN course_credits AS cc ON cc.course_layout_id = ci.course_layout_id 
AND cc.study_period = ci.study_period
JOIN activity_allocation AS aa ON aa.instance_id = ci.instance_id 
JOIN planned_activity AS pa ON ci.instance_id = pa.instance_id AND aa.activity_name = pa.activity_name
JOIN teaching_activity AS ta ON ta.activity_name = pa.activity_name
JOIN employee AS emp ON aa.employment_id = emp.employment_id
JOIN person as per ON emp.person_id = per.person_id
WHERE EXTRACT(YEAR FROM ci.start_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY "Course Code","Course Instance ID", "HP", "Period", "Teacher's Name"

)



SELECT
    "Course Code",
    "Course Instance ID",
    "HP",
    "Period",
	"Teacher's Name",
    "Lecture Hours",
    "Tutorial Hours",
    "Lab Hours",
    "Seminar Hours",
    "Admin",
	"Exam",
    ("Lecture Hours" + "Tutorial Hours" + "Lab Hours" + "Seminar Hours" + "Admin") AS "Total Calculated Hours"
FROM teacher_allocation
ORDER BY "Course Code";