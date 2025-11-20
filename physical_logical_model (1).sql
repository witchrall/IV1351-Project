CREATE TYPE study_period_type AS ENUM ('P1', 'P2', 'P3', 'P4');

CREATE TABLE course_layout (
 course_layout_id INT GENERATED ALWAYS AS IDENTITY  NOT NULL,
 course_code  VARCHAR(50) NOT NULL,
 course_name VARCHAR(200) NOT NULL,
 min_students INT NOT NULL,
 max_students INT,
 effective_from DATE NOT NULL
);

ALTER TABLE course_layout ADD CONSTRAINT PK_course_layout PRIMARY KEY (course_layout_id);


CREATE TABLE department (
 department_id INT GENERATED ALWAYS AS IDENTITY  NOT NULL,
 department_name  VARCHAR(500) NOT NULL,
 manager_employment_id INT NOT NULL
);

ALTER TABLE department ADD CONSTRAINT PK_department PRIMARY KEY (department_id);


CREATE TABLE person (
 person_id INT GENERATED ALWAYS AS IDENTITY  NOT NULL,
 personal_number  CHAR(12),
 first_name VARCHAR(500) NOT NULL,
 last_name VARCHAR(500) NOT NULL,
 zip_code CHAR(5),
 street_name VARCHAR(500),
 city VARCHAR(500)
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (person_id);


CREATE TABLE phone (
 phone_id INT GENERATED ALWAYS AS IDENTITY  NOT NULL,
 phone_number VARCHAR(50) NOT NULL
);

ALTER TABLE phone ADD CONSTRAINT PK_phone PRIMARY KEY (phone_id);


CREATE TABLE teaching_activity (
 activity_name VARCHAR(200) NOT NULL,
 factor DECIMAL(3,1)
);

ALTER TABLE teaching_activity ADD CONSTRAINT PK_teaching_activity PRIMARY KEY (activity_name);


CREATE TABLE course_credits (
 study_period study_period_type NOT NULL,
 course_layout_id INT NOT NULL,
 hp DECIMAL(3,1) NOT NULL
);

ALTER TABLE course_credits ADD CONSTRAINT PK_course_credits PRIMARY KEY (study_period,course_layout_id);


CREATE TABLE course_instance (
 instance_id  INT GENERATED ALWAYS AS IDENTITY  NOT NULL,
 num_students INT,
 study_period study_period_type NOT NULL,
 start_date DATE NOT NULL,
 course_layout_id INT NOT NULL
);

ALTER TABLE course_instance ADD CONSTRAINT PK_course_instance PRIMARY KEY (instance_id );


CREATE TABLE employee (
 employment_id  INT GENERATED ALWAYS AS IDENTITY  NOT NULL,
 skill_set VARCHAR(3000) NOT NULL,
 salary DECIMAL(10,2) NOT NULL,
 department_id INT NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE employee ADD CONSTRAINT PK_employee PRIMARY KEY (employment_id );


CREATE TABLE employee_title (
 job_title VARCHAR(500) NOT NULL,
 employment_id  INT NOT NULL
);

ALTER TABLE employee_title ADD CONSTRAINT PK_employee_title PRIMARY KEY (job_title,employment_id );


CREATE TABLE person_phone (
 person_id INT NOT NULL,
 phone_id INT NOT NULL
);

ALTER TABLE person_phone ADD CONSTRAINT PK_person_phone PRIMARY KEY (person_id,phone_id);


CREATE TABLE planned_activity (
 instance_id  INT NOT NULL,
 activity_name  VARCHAR(200) NOT NULL,
 planned_hours DECIMAL(5,2) NOT NULL
);

ALTER TABLE planned_activity ADD CONSTRAINT PK_planned_activity PRIMARY KEY (instance_id ,activity_name );


CREATE TABLE activity_allocation (
 instance_id  INT NOT NULL,
 activity_name  VARCHAR(200) NOT NULL,
 employment_id  INT NOT NULL
);

ALTER TABLE activity_allocation ADD CONSTRAINT PK_activity_allocation PRIMARY KEY (instance_id ,activity_name ,employment_id );


ALTER TABLE course_credits ADD CONSTRAINT FK_course_credits_0 FOREIGN KEY (course_layout_id) REFERENCES course_layout (course_layout_id);


ALTER TABLE course_instance ADD CONSTRAINT FK_course_instance_0 FOREIGN KEY (course_layout_id) REFERENCES course_layout (course_layout_id);


ALTER TABLE employee ADD CONSTRAINT FK_employee_0 FOREIGN KEY (department_id) REFERENCES department (department_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_1 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE employee_title ADD CONSTRAINT FK_employee_title_0 FOREIGN KEY (employment_id ) REFERENCES employee (employment_id );


ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_0 FOREIGN KEY (person_id) REFERENCES person (person_id);
ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_1 FOREIGN KEY (phone_id) REFERENCES phone (phone_id);


ALTER TABLE planned_activity ADD CONSTRAINT FK_planned_activity_0 FOREIGN KEY (instance_id ) REFERENCES course_instance (instance_id );
ALTER TABLE planned_activity ADD CONSTRAINT FK_planned_activity_1 FOREIGN KEY (activity_name ) REFERENCES teaching_activity (activity_name);


ALTER TABLE activity_allocation ADD CONSTRAINT FK_activity_allocation_0 FOREIGN KEY (instance_id ,activity_name ) REFERENCES planned_activity (instance_id ,activity_name );
ALTER TABLE activity_allocation ADD CONSTRAINT FK_activity_allocation_1 FOREIGN KEY (employment_id ) REFERENCES employee (employment_id );

ALTER TABLE employee ALTER COLUMN department_id DROP NOT NULL;

ALTER TABLE department ADD CONSTRAINT FK_department_manager FOREIGN KEY (manager_employment_id) REFERENCES employee (employment_id);

CREATE OR REPLACE FUNCTION check_teacher_load()
RETURNS trigger AS
$$
DECLARE
    course_count int;
    activity_period study_period_type;
BEGIN

    /*hämtar perioden*/
    SELECT ci.study_period
    INTO activity_period
    FROM course_instance AS ci
    WHERE NEW.instance_id = ci.instance_id;

    IF activity_period IS NULL THEN
        RAISE EXCEPTION 'No course instance found for instance_id %', NEW.instance_id;
    END IF;

    /*räkna antalet unika kursinstanser under studieperioden*/

    SELECT COUNT(DISTINCT ci.instance_id)
    INTO course_count
    FROM course_instance AS ci JOIN activity_allocation AS aa
    ON aa.instance_id = ci.instance_id
    WHERE aa.employment_id = NEW.employment_id 
    AND ci.study_period = activity_period;


    IF course_count >= 4 THEN
        RAISE EXCEPTION 'Teacher with ID % is already engaged in the maximum of 4 courses in period %', NEW.employment_id, activity_period;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_activity_allocation_max
BEFORE INSERT OR UPDATE
ON activity_allocation
FOR EACH ROW
EXECUTE FUNCTION check_teacher_load();