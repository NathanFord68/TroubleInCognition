extends Control

func _on_exit_pressed():
	get_tree().quit()

func _on_load_pressed():	
	Global.load_game()
