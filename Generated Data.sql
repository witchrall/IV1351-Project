-- ============================
-- 1. COURSE & ACTIVITY DATA
-- ============================

-- 5 course layouts
INSERT INTO course_layout (course_layout_id, course_code, course_name, min_students, max_students, effective_from)
OVERRIDING SYSTEM VALUE
VALUES
  (1, 'DD1010', 'Intro to Databases',          10, 100, DATE '2024-01-01'),
  (2, 'DD1020', 'Advanced SQL',                10,  60, DATE '2024-01-01'),
  (3, 'DD1030', 'Software Engineering',        15, 120, DATE '2024-01-01'),
  (4, 'DD1040', 'Algorithms',                  10,  80, DATE '2024-01-01'),
  (5, 'DD1050', 'Operating Systems',           10,  70, DATE '2024-01-01');

-- Teaching activities
INSERT INTO teaching_activity (activity_name, factor)
VALUES
  ('Lecture', 1.0),
  ('Lab',     0.5),
  ('Seminar', 0.8),
  ('Exam',    0.2);

-- Course credits (hp) per study period
INSERT INTO course_credits (study_period, course_layout_id, hp)
VALUES
  ('P1', 1, 7.5),
  ('P2', 2, 7.5),
  ('P3', 3, 7.5),
  ('P4', 4, 7.5),
  ('P1', 5, 7.5);

-- Course instances
INSERT INTO course_instance (instance_id, num_students, study_period, start_date, course_layout_id)
OVERRIDING SYSTEM VALUE
VALUES
  (1, 50, 'P1', DATE '2024-01-15', 1),
  (2, 40, 'P2', DATE '2024-03-15', 2),
  (3, 60, 'P3', DATE '2024-09-01', 3),
  (4, 55, 'P4', DATE '2024-11-01', 4),
  (5, 30, 'P1', DATE '2024-01-20', 5);

-- ============================
-- 2. PERSON & PHONE DATA
--    60 persons, 20 phones
-- ============================

-- 60 persons with synthetic data
INSERT INTO person (person_id, personal_number, first_name, last_name, zip_code, street_name, city)
OVERRIDING SYSTEM VALUE
SELECT
  gs AS person_id,
  -- YYYYMMDD + 4-digit suffix = 12 chars
  to_char(DATE '1990-01-01' + (gs % 365), 'YYYYMMDD') || LPAD(gs::text, 4, '0') AS personal_number,
  'FirstName' || gs AS first_name,
  'LastName'  || gs AS last_name,
  LPAD((10000 + gs)::text, 5, '0') AS zip_code,
  'Street ' || gs AS street_name,
  'City '   || ((gs % 5) + 1) AS city
FROM generate_series(1, 60) AS gs;

-- 20 phones
INSERT INTO phone (phone_id, phone_number)
OVERRIDING SYSTEM VALUE
SELECT
  gs AS phone_id,
  '+4670' || LPAD((100000 + gs)::text, 6, '0') AS phone_number
FROM generate_series(1, 20) AS gs;

-- Link first 20 persons to one phone each
INSERT INTO person_phone (person_id, phone_id)
SELECT
  gs AS person_id,
  gs AS phone_id
FROM generate_series(1, 20) AS gs;

-- ============================
-- 3. EMPLOYEES (60) AND DEPARTMENTS (5)
-- ============================

-- 60 employees, initially without department (department_id = NULL)
INSERT INTO employee (employment_id, skill_set, salary, department_id, person_id)
OVERRIDING SYSTEM VALUE
SELECT
  gs AS employment_id,
  'Skill set for employee ' || gs AS skill_set,
  30000.00 + (gs * 500.00)  AS salary,
  NULL::INT                 AS department_id,
  gs                        AS person_id
FROM generate_series(1, 60) AS gs;

-- 5 departments, each with a manager (employee IDs chosen as managers)
INSERT INTO department (department_id, department_name, manager_employment_id)
OVERRIDING SYSTEM VALUE
VALUES
  (1, 'Computer Science',       1),
  (2, 'Information Systems',   13),
  (3, 'Mathematics',           25),
  (4, 'Electrical Engineering',37),
  (5, 'Mechanical Engineering',49);

-- Now assign each employee to a department
-- Employees:
-- 1-12  -> dept 1
-- 13-24 -> dept 2
-- 25-36 -> dept 3
-- 37-48 -> dept 4
-- 49-60 -> dept 5
UPDATE employee
SET department_id =
  CASE
    WHEN employment_id BETWEEN  1 AND 12 THEN 1
    WHEN employment_id BETWEEN 13 AND 24 THEN 2
    WHEN employment_id BETWEEN 25 AND 36 THEN 3
    WHEN employment_id BETWEEN 37 AND 48 THEN 4
    ELSE 5
  END;

-- ============================
-- 4. EMPLOYEE TITLES
--    1 title per employee
-- ============================

INSERT INTO employee_title (job_title, employment_id)
SELECT
  CASE
    WHEN employment_id % 5 = 1 THEN 'Professor'
    WHEN employment_id % 5 = 2 THEN 'Associate Professor'
    WHEN employment_id % 5 = 3 THEN 'Lecturer'
    WHEN employment_id % 5 = 4 THEN 'Teaching Assistant'
    ELSE 'Administrator'
  END AS job_title,
  employment_id
FROM employee;

-- ============================
-- 5. PLANNED ACTIVITIES & ALLOCATIONS
-- ============================

-- Planned activities for course instances
INSERT INTO planned_activity (instance_id, activity_name, planned_hours)
VALUES
  (1, 'Lecture', 20.0),
  (1, 'Lab',     10.0),
  (2, 'Lecture', 18.0),
  (2, 'Lab',     12.0),
  (3, 'Lecture', 22.0),
  (3, 'Seminar',  8.0),
  (4, 'Lecture', 20.0),
  (4, 'Exam',     5.0),
  (5, 'Lecture', 16.0);

-- Allocate some employees to those planned activities
INSERT INTO activity_allocation (instance_id, activity_name, employment_id)
VALUES
  (1, 'Lecture', 1),
  (1, 'Lecture', 2),
  (1, 'Lab',     3),
  (2, 'Lecture', 4),
  (2, 'Lab',     5),
  (3, 'Lecture', 6),
  (3, 'Seminar', 7),
  (4, 'Lecture', 8),
  (4, 'Exam',    9),
  (5, 'Lecture',10);
