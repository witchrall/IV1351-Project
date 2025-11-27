/* SEM2 view1 */
CREATE VIEW planned_hours AS 
 WITH calculated_hours AS (
         SELECT cl.course_code AS "Course Code",
            ci.instance_id AS "Course Instance ID",
            cc.hp AS "HP",
            cc.study_period AS "Period",
            sum(ci.num_students) AS "#Students",
            sum(
                CASE
                    WHEN pa.activity_name::text = 'Lecture'::text THEN pa.planned_hours
                    ELSE 0::numeric
                END) * (( SELECT ta_1.factor
                   FROM teaching_activity ta_1
                  WHERE ta_1.activity_name::text = 'Lecture'::text)) AS "Lecture Hours",
            sum(
                CASE
                    WHEN pa.activity_name::text = 'Tutorial'::text THEN pa.planned_hours
                    ELSE 0::numeric
                END) * (( SELECT ta_1.factor
                   FROM teaching_activity ta_1
                  WHERE ta_1.activity_name::text = 'Tutorial'::text)) AS "Tutorial Hours",
            sum(
                CASE
                    WHEN pa.activity_name::text = 'Lab'::text THEN pa.planned_hours
                    ELSE 0::numeric
                END) * (( SELECT ta_1.factor
                   FROM teaching_activity ta_1
                  WHERE ta_1.activity_name::text = 'Lab'::text)) AS "Lab Hours",
            sum(
                CASE
                    WHEN pa.activity_name::text = 'Seminar'::text THEN pa.planned_hours
                    ELSE 0::numeric
                END) * (( SELECT ta_1.factor
                   FROM teaching_activity ta_1
                  WHERE ta_1.activity_name::text = 'Seminar'::text)) AS "Seminar Hours",
            sum(
                CASE
                    WHEN pa.activity_name::text = 'Administration'::text THEN pa.planned_hours
                    ELSE 0::numeric
                END) * (( SELECT ta_1.factor
                   FROM teaching_activity ta_1
                  WHERE ta_1.activity_name::text = 'Administration'::text)) AS "Admin",
            sum(
                CASE
                    WHEN pa.activity_name::text = 'Examination'::text THEN pa.planned_hours
                    ELSE 0::numeric
                END) * (( SELECT ta_1.factor
                   FROM teaching_activity ta_1
                  WHERE ta_1.activity_name::text = 'Examination'::text)) AS "Exam"
           FROM course_instance ci
             JOIN ( SELECT DISTINCT course_layout.course_code,
                    course_layout.course_layout_id
                   FROM course_layout) cl ON ci.course_layout_id = cl.course_layout_id
             JOIN course_credits cc ON cc.course_layout_id = ci.course_layout_id AND cc.study_period = ci.study_period
             LEFT JOIN planned_activity pa ON pa.instance_id = ci.instance_id
             LEFT JOIN teaching_activity ta ON ta.activity_name::text = pa.activity_name::text
          WHERE EXTRACT(year FROM ci.start_date) = EXTRACT(year FROM CURRENT_DATE)
          GROUP BY cl.course_code, cc.study_period, ci.instance_id, cc.hp
        )
SELECT 
    "Course Code",
    "Course Instance ID",
    "HP",
    "Period",
    "#Students",
    "Lecture Hours",
    "Tutorial Hours",
    "Lab Hours",
    "Seminar Hours",
    "Admin",
    "Exam",
    "Lecture Hours" + "Tutorial Hours" + "Lab Hours" + "Seminar Hours" + "Admin" AS "Total Calculated Hours"
FROM calculated_hours
ORDER BY "Course Code";



/* SEM2 view2 */
 CREATE VIEW allocated_hours AS
 WITH allocated_per_teacher AS (
         SELECT cl.course_code AS "Course Code",
            ci.instance_id AS "Course Instance ID",
            cc.hp AS "HP",
            concat(per.first_name, ' ', per.last_name) AS "Teacher's Name",
                CASE
                    WHEN pa.activity_name::text = 'Lecture'::text THEN pa.planned_hours
                    ELSE 0
                END * (( SELECT ta.factor
                   FROM teaching_activity ta
                  WHERE ta.activity_name::text = 'Lecture'::text)) AS "Lecture Hours",
                CASE
                    WHEN pa.activity_name::text = 'Tutorial'::text THEN pa.planned_hours
                    ELSE 0
                END * (( SELECT ta.factor
                   FROM teaching_activity ta
                  WHERE ta.activity_name::text = 'Tutorial'::text)) AS "Tutorial Hours",
                CASE
                    WHEN pa.activity_name::text = 'Lab'::text THEN pa.planned_hours
                    ELSE 0
                END * (( SELECT ta.factor
                   FROM teaching_activity ta
                  WHERE ta.activity_name::text = 'Lab'::text)) AS "Lab Hours",
                CASE
                    WHEN pa.activity_name::text = 'Seminar'::text THEN pa.planned_hours
                    ELSE 0
                END * (( SELECT ta.factor
                   FROM teaching_activity ta
                  WHERE ta.activity_name::text = 'Seminar'::text)) AS "Seminar Hours",
                CASE
                    WHEN pa.activity_name::text = 'Administration'::text THEN pa.planned_hours
                    ELSE 0
                END * (( SELECT ta.factor
                   FROM teaching_activity ta
                  WHERE ta.activity_name::text = 'Administration'::text)) AS "Admin",
                CASE
                    WHEN pa.activity_name::text = 'Examination'::text THEN pa.planned_hours
                    ELSE 0
                END * (( SELECT ta.factor
                   FROM teaching_activity ta
                  WHERE ta.activity_name::text = 'Examination'::text)) AS "Exam"
           FROM course_instance ci
             JOIN ( SELECT course_layout.course_code,
                    course_layout.course_layout_id
                   FROM course_layout) cl ON ci.course_layout_id = cl.course_layout_id
             JOIN course_credits cc ON cc.course_layout_id = ci.course_layout_id AND cc.study_period = ci.study_period
             JOIN planned_activity pa ON ci.instance_id = pa.instance_id
             JOIN activity_allocation aa ON aa.instance_id = ci.instance_id
             JOIN employee emp ON aa.employment_id = emp.employment_id
             JOIN person per ON emp.person_id = per.person_id
          WHERE EXTRACT(year FROM ci.start_date) = EXTRACT(year FROM CURRENT_DATE)
        )
SELECT 
    "Course Code",
    "Course Instance ID",
    "HP",
    "Teacher's Name",
    "Lecture Hours",
    "Lab Hours",
    "Seminar Hours",
    "Admin",
    "Exam",
    ("Lecture Hours" + "Tutorial Hours" + "Lab Hours" + "Seminar Hours" + "Admin") AS "Total Calculated Hours"
FROM allocated_per_teacher
ORDER BY "Course Code";


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



/*SEM2 view4 */
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