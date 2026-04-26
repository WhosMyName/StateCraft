class_name BaseTile extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func disconnect_signal(sig: Signal) -> void:
	for conn in sig.get_connections():
		sig.disconnect(conn["callable"])


func select_file(title: String):
	var window: FileDialog = FileDialog.new()
	window.access = FileDialog.ACCESS_FILESYSTEM
	window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	window.use_native_dialog = true # Optional: uses OS native picker
	window.mode_overrides_title = false
	window.title = title
	window.file_selected.connect(self.load_from_file)
	self.add_child(window)
	window.popup_centered()
	window.size = Vector2(1024, 576)
	window.position = self.get_parent().get_parent_area_size() / 2
