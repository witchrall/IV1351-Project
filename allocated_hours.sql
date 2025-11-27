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
 SELECT "Course Code",
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