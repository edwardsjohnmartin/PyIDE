<?php
require_once('controllers/base_controller.php');
class SurveyController extends BaseController
{
	public function index(){
		$models = ($this->model_name)::get_pairs();
		$view_to_show = 'views/shared/index.php';
		require_once('views/shared/layout.php');
	}

	public function create(){
		//TODO: Make a custom create view for this action
		//It will need to be able to set name, instructions, survey type, and concept
		//Also needs to be able to set lesson, but only if survey type is 'Pre Lesson' or 'Post Lesson'
		//It will need:
		// add question button
		// add choice button
		// delete question button
		// delete choice button
		// way to reorder questions
		// way to reorder choices
		//To be able to save:
		// survey needs at least 1 question
		// questions needs at least 2 choices
		// lesson must be null unless survey type is 'Pre Lesson' or 'Post Lesson'
		// if lesson is set, it must be in the concept
	}
}
?>