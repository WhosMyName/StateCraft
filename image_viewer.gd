class_name ImageViewerTile extends BaseTile
# add filetype_not_supported.png and handling

var image: TextureRect = null
var select_file_button: Button = null
var delete_node_button: Button = null
var file_path: String = ""


#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.image = TextureRect.new()
	self.image.size = Vector2(200, 200)
	self.image.custom_minimum_size = self.image.size
	self.image.texture = preload("res://icons/clock.svg")
	self.image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	self.image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	self.select_file_button = Button.new()
	self.select_file_button.icon = preload("res://icons/Godot/Edit.svg")
	self.select_file_button.tooltip_text = "Click to select a file"
	self.delete_node_button = Button.new()
	self.delete_node_button.icon = preload("res://icons/trash.svg")
	self.delete_node_button.tooltip_text = "Click to delete this tile"
	
	var button_hbox = HBoxContainer.new()
	button_hbox.add_child(self.select_file_button)
	button_hbox.add_spacer(false)
	button_hbox.add_child(self.delete_node_button)
	
	var vbox = VBoxContainer.new()
	vbox.add_child(HSeparator.new())
	vbox.add_child(self.image)
	vbox.add_child(button_hbox)
	
	self.add_child(vbox)
	
	self.delete_node_button.pressed.connect(self.close)
	self.select_file_button.pressed.connect(self.select_file.bind("Open Image:"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func close() -> void:
	disconnect_signal(self.delete_node_button.pressed)
	disconnect_signal(self.select_file_button.pressed)
	self.get_parent().remove_child(self)
	queue_free()
#endregion

#region Save/Load Data
func save() -> Dictionary:
	var data: Dictionary = {
		"name": "ImageViewerTile",
		"path": self.file_path
	}
	return data

func load(data: Dictionary) -> void:
	pass
#endregion

func load_from_path(path) -> void:
	self.file_path = path
	self.image.texture = ImageTexture.create_from_image(Image.load_from_file(path))
