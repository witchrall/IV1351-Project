CREATE VIEW planned_hours AS 
WITH calculated_hours AS (
    SELECT 
        cl.course_code AS "Course Code",
        ci.instance_id AS "Course Instance ID",
        cc.hp AS "HP",
        cc.study_period AS "Period",
        SUM(ci.num_students) AS "#Students",
        
        SUM(CASE WHEN pa.activity_name = 'Lecture'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Lecture') AS "Lecture Hours",

        SUM(CASE WHEN pa.activity_name = 'Tutorial'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Tutorial') AS "Tutorial Hours",

        SUM(CASE WHEN pa.activity_name = 'Lab'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Lab') AS "Lab Hours",

        SUM(CASE WHEN pa.activity_name = 'Seminar'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Seminar') AS "Seminar Hours",

        SUM(CASE WHEN pa.activity_name = 'Administration'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Administration') AS "Admin",
		SUM(CASE WHEN pa.activity_name = 'Examination'
            THEN pa.planned_hours END) *
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Examination') AS "Exam"	
        
    FROM course_instance AS ci 
	JOIN (SELECT DISTINCT course_code, course_layout_id FROM course_layout ) AS cl ON ci.course_layout_id = cl.course_layout_id
    JOIN course_credits cc ON cc.course_layout_id = ci.course_layout_id AND cc.study_period = ci.study_period
    LEFT JOIN planned_activity pa ON pa.instance_id = ci.instance_id
    LEFT JOIN teaching_activity ta ON ta.activity_name = pa.activity_name
    WHERE EXTRACT(YEAR FROM ci.start_date) = EXTRACT(YEAR FROM CURRENT_DATE)
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
    COALESCE("Lecture Hours", 0) + COALESCE("Tutorial Hours", 0) + COALESCE("Lab Hours", 0)
	+ COALESCE("Seminar Hours", 0)
	+ COALESCE("Admin", 0)
	 AS "Total Calculated Hours"
FROM calculated_hours
ORDER BY "Course Code";
