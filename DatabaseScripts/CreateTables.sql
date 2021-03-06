CREATE TABLE roles (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE users (
	id serial PRIMARY KEY,
	email text NOT NULL UNIQUE,
	name text NOT NULL,
	hash text NOT NULL, -- 32 bytes for sha-256
	salt text NOT NULL, -- ?
	role_id integer REFERENCES roles NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE permission_types (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE securables (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE permissions_to_roles (
	role_id integer REFERENCES roles NOT NULL,
	permission_type_id integer REFERENCES permission_types NOT NULL,
	securable_id integer REFERENCES securables NOT NULL
);

CREATE TABLE participation_types (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE languages (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE tags (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE exercises (
	id serial PRIMARY KEY,
	name text NOT NULL, -- if this is null, it should be the description...
	description text NOT NULL,
	test_code text NOT NULL,
	-- hash uuid, -- probably won't use this
	language_id integer REFERENCES languages NOT NULL,
	make_file text,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE exercise_starter_code_files(
	id serial PRIMARY KEY,
	exercise_id integer REFERENCES exercises NOT NULL,
	name text,
	contents text,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE projects (
	id serial PRIMARY KEY,
	name text NOT NULL, -- if this is null, it should be the description...
	description text NOT NULL,
	-- hash uuid,
	language_id integer REFERENCES languages NOT NULL,
	make_file text,
	max_grade double precision NOT NULL,
	owner_id integer REFERENCES users NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE project_starter_code_files(
	id serial PRIMARY KEY,
	project_id integer REFERENCES projects NOT NULL,
	name text,
	contents text,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE lessons (
	id serial PRIMARY KEY,
	name text NOT NULL,
	description text NOT NULL,
	owner_id integer REFERENCES users NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE completion_status (
	id serial PRIMARY KEY,
	name text NOT NULL,
	importance integer CHECK(inverse_importance >= 0) UNIQUE, -- this is for getting the status of exercises, lessons, etc. the highest importance will be chosen for the lesson status based on the exercise statuses!
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE courses (
	id serial PRIMARY KEY,
	name text NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE sections (
	id serial PRIMARY KEY,
	name text NOT NULL,
	course_id integer REFERENCES courses NOT NULL,
	teacher_id integer REFERENCES users NOT NULL,
	start_date timestamp NOT NULL,
	end_date timestamp NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

-- modules
CREATE TABLE concepts ( -- order by date? have an order?
	id serial PRIMARY KEY,
	name text NOT NULL,
	section_id integer REFERENCES sections NOT NULL,
	open_date timestamp NOT NULL,
	project_id integer REFERENCES projects NOT NULL,
	project_open_date timestamp NOT NULL,
	project_due_date timestamp NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE tags_to_exercises (
	tag_id integer REFERENCES tags NOT NULL,
	exercise_id integer REFERENCES exercises NOT NULL
);

CREATE TABLE exercises_to_lessons (
	exercise_id integer REFERENCES exercises NOT NULL,
	lesson_id integer REFERENCES lessons NOT NULL,
	exercise_number integer NOT NULL
);

CREATE TABLE lessons_to_concepts (
	lesson_id integer REFERENCES lessons NOT NULL,
	concept_id integer REFERENCES concepts NOT NULL,
	lesson_number integer NOT NULL
);

CREATE TABLE project_teams (
	id serial PRIMARY KEY,
	concept_id integer REFERENCES concepts NOT NULL, -- there should be a constraint so that concept/user pairs are unique
	is_deleted boolean DEFAULT false NOT NULL
);

CREATE TABLE users_to_project_teams (
	project_team_id integer REFERENCES project_teams NOT NULL,
	user_id integer REFERENCES users NOT NULL
);

-- where to put the code?
/*
CREATE TABLE project_code_files ( -- i need multiple files
	id serial PRIMARY KEY,
	team_id integer REFERENCES project_teams NOT NULL,
	name text,
	contents text,
	is_deleted boolean DEFAULT false NOT NULL
);
*/

-- right now i'm assuming one file. need to think about updating files for multiple users with multiple files...
CREATE TABLE project_code_files_for_users (
	id serial PRIMARY KEY, -- currently not necessary
	user_id integer REFERENCES users NOT NULL,
	concept_id integer REFERENCES concepts NOT NULL,
	name text,
	contents text,
	is_deleted boolean DEFAULT false NOT NULL,
	UNIQUE(user_id, concept_id) -- i've added a constraint to make sure only one file. can be removed later.
);

CREATE TABLE completion_status_to_exercise (
	exercise_id integer REFERENCES exercises NOT NULL,
	lesson_id integer REFERENCES lessons NOT NULL,
	concept_id integer REFERENCES concepts NOT NULL,
	date_updated timestamp NOT NULL,
	completion_status_id integer REFERENCES completion_status NOT NULL,
	user_id integer REFERENCES users NOT NULL
);

--this needs to be changed, too?
CREATE TABLE completion_status_to_project ( 
	date_updated timestamp NOT NULL,
	completion_status_id integer REFERENCES completion_status NOT NULL,
	project_team_id integer REFERENCES project_teams NOT NULL -- team is unique for concept
);

CREATE TABLE project_grades ( -- might need a better name
	project_id integer REFERENCES projects NOT NULL, -- since each concept has only one project, i don't need this
	concept_id integer REFERENCES concepts NOT NULL,
	team_id integer REFERENCES project_teams NOT NULL, -- are there any other ids i need?
	grade double precision NOT NULL
);

CREATE TABLE users_to_sections ( -- monikers probably need to go here... also need to make sure they're unique per section
	user_id integer REFERENCES users NOT NULL,
	section_id integer REFERENCES sections NOT NULL,
	participation_type_id integer REFERENCES participation_types NOT NULL -- not teacher. grader or student.
);

CREATE TABLE functions (
	id serial PRIMARY KEY,
	section_id integer REFERENCES sections NOT NULL,
	user_id integer REFERENCES users NOT NULL,
	name text NOT NULL,
	code text,
	is_deleted boolean DEFAULT false NOT NULL,
	UNIQUE(section_id, user_id, name)
);

CREATE TYPE key_value_pair AS (key integer, value text);
CREATE TYPE key_value_status AS (key integer, value text, status integer);
CREATE TYPE user_partial AS (id integer, email text, name text, role integer);
