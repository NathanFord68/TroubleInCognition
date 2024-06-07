extends Control

func pause_game() -> void:
	visible = true
	get_tree().paused = true

func _on_resume_button_pressed():
	visible = false
	get_tree().paused = false
