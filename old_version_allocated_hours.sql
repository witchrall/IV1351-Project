

CREATE VIEW allocated_hours1 AS
WITH allocated_per_teacher AS (
SELECT 
	cl.course_code AS "Course Code",
	ci.instance_id AS "Course Instance ID",
	cc.hp AS "HP", 
	(SELECT 
		CONCAT(person.first_name, ' ', person.last_name) AS full_name
		FROM person
		WHERE e.person_id = person.person_id AND e.employment_id = aa.employment_id
	) AS "Teacher's Name",
	(SELECT 
		job_title
		FROM employee_title
		WHERE p.person_id = employee_title.employment_id
	) AS "Designation",
	
	
	(CASE WHEN pa.activity_name = 'Lecture'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Lecture') AS "Lecture Hours",

       (CASE WHEN pa.activity_name = 'Tutorial'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Tutorial') AS "Tutorial Hours",

        (CASE WHEN pa.activity_name = 'Lab'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Lab') AS "Lab Hours",

        (CASE WHEN pa.activity_name = 'Seminar'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Seminar') AS "Seminar Hours",

        (CASE WHEN pa.activity_name = 'Administration'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Administration') AS "Admin",
		(CASE WHEN pa.activity_name = 'Examination'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Examination') AS "Exam"	
	/*
	FROM course_layout cl
    JOIN course_instance ci ON ci.instance_id = cl.course_layout_id
    JOIN course_credits cc ON cc.course_layout_id = cl.course_layout_id
	
	JOIN employee ON employee.person_id = person.person_id
	JOIN activity_allocation aa ON employee.employment_id = aa.employment_id
	JOIN person ON person.person_id = employee_title.employment_id
	JOIN activity_allocation ON planned_activity.instance_id = aa.instance_id AND planned_activity.activity_name = aa.activity_name
	
    LEFT JOIN planned_activity pa ON pa.instance_id = ci.instance_id
    LEFT JOIN teaching_activity ta ON ta.activity_name = pa.activity_name
    WHERE ci.instance_id = aa.instance_id
	*/
	-- test, remove
	FROM course_layout cl
    JOIN course_instance ci ON ci.instance_id = cl.course_layout_id
    JOIN course_credits cc ON cc.course_layout_id = cl.course_layout_id
    JOIN activity_allocation aa ON ci.instance_id = aa.instance_id
    JOIN planned_activity pa ON pa.instance_id = ci.instance_id
                              AND pa.activity_name = aa.activity_name
    JOIN employee e ON aa.employment_id = e.employment_id
    JOIN person p ON e.person_id = p.person_id
    JOIN employee_title et ON e.employment_id = et.employment_id
    WHERE ci.instance_id = aa.instance_id
	
    --GROUP BY cl.course_code, cc.study_period, ci.instance_id, cc.hp
)

SELECT 
	"Course Code",
	"Course Instance ID",
	"HP", 
	"Teacher's Name",
	"Designation",
	"Lecture Hours",
	"Lab Hours",
	"Seminar Hours",
	"Admin",
	"Exam",
	("Lecture Hours" + "Lab Hours" + "Seminar Hours" + "Admin" + "Exam") AS "Total Hours"
FROM allocated_per_teacher
ORDER BY "Course Code"
