class_name BaseTile extends Control

#var _id = 0 # layer id
#var iid = 0
#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self._iid = self.get_instance_id()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

func save(data: Dictionary = {}) -> Dictionary:
	return data
	
func load_data(_data: Dictionary) -> void:
	pass
#endregion

#region Getter/Setter
#func get_id() -> int:
	#return self._id
	
#func set_id(nid: int) -> void:
	#self._id = nid
#endregion

#region Signalhandling
func disconnect_signal(sig: Signal) -> void:
	for conn in sig.get_connections():
		sig.disconnect(conn["callable"])
#endregion

#region File Selection handling
func select_file(title: String):
	var window: FileDialog = FileDialog.new()
	window.access = FileDialog.ACCESS_FILESYSTEM
	window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	window.use_native_dialog = true # Optional: uses OS native picker
	window.mode_overrides_title = false
	window.title = title
	window.file_selected.connect(self.load_from_path)
	self.add_child(window)
	window.popup_centered()
	window.size = Vector2(1024, 576)
	window.position = self.get_parent().get_parent_area_size() / 2
#endregion
