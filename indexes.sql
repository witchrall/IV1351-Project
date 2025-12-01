--the indexes create during SEM2

CREATE INDEX instance_id_index
ON activity_allocation(isntance_id);

CREATE INDEX employment_id_index
ON activity_allocation(employment_id);

CREATE INDEX activity_name_index
ON planned_activity(activity_name);


CREATE INDEX person_id_index
ON employee(person_id);

CREATE INDEX course_layout_id_index
ON course_instance(course_layout_id);

