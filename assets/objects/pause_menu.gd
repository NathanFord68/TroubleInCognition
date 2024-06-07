extends Control

func pause_game() -> void:
	visible = true
	get_tree().paused = true

func _on_resume_button_pressed():
	visible = false
	get_tree().paused = false


func _on_quit_to_desktop_pressed():
	Global.save_game("AutoSave-Close")
	get_tree().quit()


func _on_quit_to_main_menu_pressed():
	Global.save_game("AutoSave-Close")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_save_pressed():
	visible = false
	$"../SaveMenu".visible = true
