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
 SELECT "Course Code",
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