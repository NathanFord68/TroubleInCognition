extends Control

var did_just_open: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$LineEdit.text = Global.save_file_name
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
		b.pressed.connect(handle_save_file_clicked)
		$SaveFiles.add_child(b)
	
func handle_save_file_clicked(data = null):
	print(data)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("player_escape") and visible:
		visible = false
		$"../PauseMenu".visible = true

func handle_save():
	if Global.save_file_name.is_empty():
		$"../../PlayerHud".add_message.emit("Must have a valid file name to save.")
		return
	Global.save_game()
func _on_line_edit_text_changed(new_text):
	Global.save_file_name = new_text

func _on_save_pressed():
	handle_save()

func _on_line_edit_text_submitted(_new_text):
	handle_save()
