<?php
	require_once('models/model.php');
	class Concept extends Model
	{
		protected static $types = array('id' => Type::INTEGER, 'name' => Type::STRING, 'section' => Type::SECTION, 'project' => Type::PROJECT, 'project_open_date' => Type::DATETIME, 'project_due_date' => Type::DATETIME, 'lessons' => Type::LIST_LESSON); //use the enum
		protected $name;
		protected $section;
		protected $project;
		protected $project_open_date;
		protected $project_due_date;
		protected $lessons;

		//this needs to be by section and user to get progress, but for now it is just for section...
		public static function get_all_for_section($section_id) //expecting multiple
		{
			$db = Db::getReader();
			$section_id = intval($section_id);

			$function_name = 'sproc_read_concept_get_all_for_section';
			$req = $db->prepare(static::build_query($function_name, array('section_id')));
			$req->execute(array('section_id' => $section_id));

			return $req->fetchAll(PDO::FETCH_CLASS, 'concept');
		}

		public static function get_all_for_section_and_user($section_id, $user_id) //expecting multiple
		{
			$db = Db::getReader();
			$section_id = intval($section_id);
			$user_id = intval($user_id);

			$function_name = 'sproc_read_concept_get_all_for_section_and_user';
			$req = $db->prepare(static::build_query($function_name, array('section_id', 'user_id')));
			$req->execute(array('section_id' => $section_id, 'user_id' => $user_id));

			return $req->fetchAll(PDO::FETCH_CLASS, 'concept');
		}

		public static function get_for_user($id, $user_id)
		{
			$db = Db::getReader();
			$id = intval($id);
			$user_id = intval($user_id);

			$function_name = 'sproc_read_concept_get_for_user';
			$req = $db->prepare(static::build_query($function_name, array('id', 'user_id')));
			$req->execute(array('id' => $id, 'user_id' => $user_id));

			$req->setFetchMode(PDO::FETCH_CLASS,  $model_name);
			return $req->fetch(PDO::FETCH_CLASS);
		}

	}
?>
