WITH calculated_hours AS (
    SELECT 
        cl.course_code AS "Course Code",
        ROUND(AVG(ci.instance_id), 0) AS "Course Instance ID",
        ROUND(AVG(cc.hp),0) AS "HP",
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
            (SELECT factor FROM teaching_activity ta WHERE ta.activity_name = 'Administration') AS "Admin"
        
    FROM course_layout cl
    JOIN course_instance ci ON ci.instance_id = cl.course_layout_id
    JOIN course_credits cc ON cc.course_layout_id = cl.course_layout_id
    LEFT JOIN planned_activity pa ON pa.instance_id = ci.instance_id
    LEFT JOIN teaching_activity ta ON ta.activity_name = pa.activity_name
    WHERE EXTRACT(YEAR FROM ci.start_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY cl.course_code, cc.study_period
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
    ("Lecture Hours" + "Tutorial Hours" + "Lab Hours" + "Seminar Hours" + "Admin") AS "Total Calculated Hours"
FROM calculated_hours
ORDER BY "Course Code";
