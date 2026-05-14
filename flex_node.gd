class_name FlexNode extends BaseNode
# TODO: handle resizing generally (both tiles and node)
# TODO: use hseparator as resize bar
# TODO: fix slots not removed when tile is removed

var add_button_container: VBoxContainer = null
var add_elem_button: MenuButton = null
var color_left = Color(0,1,0)
var color_right = Color(1,0,0)
var tiles: Array[BaseTile] = []

#region Init/Ready/Process/Close
func _init() -> void:
	pass

func _ready() -> void:
	super._ready()
	self.add_button_container = VBoxContainer.new()
	self.add_elem_button = MenuButton.new()
	self.add_elem_button.icon = preload("res://icons/add_layer.svg")
	self.add_elem_button.get_popup().add_item("Text", 0)
	self.add_elem_button.get_popup().add_item("Markdown", 1)
	self.add_elem_button.get_popup().add_item("Image", 2)
	self.add_elem_button.get_popup().add_item("Audio", 3)
	self.add_elem_button.get_popup().add_item("Video", 4)
	self.add_elem_button.get_popup().id_pressed.connect(self.add_elem)
	self.add_button_container.add_child(HSeparator.new())
	var center_container  = CenterContainer.new()
	center_container.add_child(self.add_elem_button)
	self.add_button_container.add_child(center_container)
	self.add_child(self.add_button_container)

	self.resizable = true
	self.custom_minimum_size = Vector2(60, 60)
	self.set_size(Vector2(100, 100))
	self.set_title("FlexNode")

func _process(_delta: float) -> void:
	pass

func close() -> void:
	queue_free()
#endregion

#region Getter/Setter
func set_transparency() -> void:
	# TODO: implement
	pass
	
func set_bg_color() -> void:
	# TODO: implement
	pass
#endregion

#region Load/Save Data
func load_data(data: Dictionary) -> void:
	self.color_left = JSON.to_native(data["color_left"])
	self.color_right = JSON.to_native(data["color_right"])
	for tile_data in data["tiles"]:
		var tile: BaseTile = null
		match tile_data["name"]:
			"TextEditorTile": tile = add_elem(0)
			"MarkDownEditorTile": tile = add_elem(1)
			"ImageViewerTile": tile = add_elem(2)
			"AudioPlayerTile": tile = add_elem(3)
			"VideoPlayerTile": tile = add_elem(4)
		tile.load_data(tile_data)
	super.load_data(data)

func save(data: Dictionary = {}) -> Dictionary:
	# TODO: save files from tiles (and switch to internal path)
	data = {
		"color_left": JSON.from_native(self.color_left),
		"color_right": JSON.from_native(self.color_right),
		"tiles": []
	}
	for tile in self.tiles:
		data["tiles"].append(tile.save())
	return super.save(data)
#endregion

#region Node Element Handling
func add_tile(tile: BaseTile, elem_size: Vector2):
	self.tiles.append(tile)
	tile.size = elem_size
	tile.custom_minimum_size = elem_size
	self.add_child(tile)
	# self.get_child_count() - 2, because self.add_button_container and reordering from below
	self.set_slot(self.get_child_count() - 2, true, 0, self.color_left, true, 0, self.color_right)
	self.move_child(self.add_button_container, self.get_child_count() - 1)

func add_elem(id) -> BaseTile:
	# dynamically load element types (plaintext, markdown, video, audio, image)
	var tile: BaseTile = null
	if id == 0: # PlainText
		tile = TextEditorTile.new()
		self.add_tile(tile, Vector2(200, 235))
	elif id == 1: # Markdown+
		tile = MarkDownEditorTile.new()
		self.add_tile(tile, Vector2(200, 240))
	elif id == 2: # Image
		tile = ImageViewerTile.new()
		self.add_tile(tile, Vector2(200, 240))
	elif id == 3: # Saund
		tile = AudioPlayerTile.new()
		self.add_tile(tile, Vector2(185, 120))
	elif id == 4: # WHOOOP, OK GARMIN, FIDEO SPEICHERN!
		tile = VideoPlayerTile.new()
		self.add_tile(tile, Vector2(450, 450))
	else:
		pass
	self.size = Vector2(0, 0)
	return tile

#endregion
