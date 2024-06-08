extends HBoxContainer

func _on_exit_pressed():
	get_tree().quit()


func _on_load_pressed():
	visible = false
	$"../LoadMenu".visible = true
