extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.save_file_name = ""
	var dir := DirAccess.open("user://saves")
	if not is_instance_valid(dir):
		return
	dir.list_dir_begin()
	var filename
	while true:
		filename = dir.get_next()
		if filename == "":
			break
		var b := Button.new()
		b.text = filename.trim_suffix(".save")
		b.pressed.connect(handle_save_file_clicked.bind(b.text))
		$ScrollContainer/SavedFiles.add_child(b)
		$LoadButton.disabled = true
		
func handle_save_file_clicked(save_file_name: String) -> void:
	Global.save_file_name = save_file_name
	$FileLabel.text = save_file_name
	$LoadButton.disabled = false

func _on_load_button_pressed():
	Global.load_game()
