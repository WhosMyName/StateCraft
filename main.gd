class_name MainWindow extends Node2D
# TODO: fix the leaky mem

var activeGraphLayer: Layer = null
var last_layer_num = 1 # only needed if previous layer is interactable
var top_menu: TopMenu = null
var layers: Array[Layer] = []
var hbox_size: Vector2 = Vector2()
var last_save_path: String = ""
var file_extension = ".csm"

#region Load/Save Data
# https://docs.godotengine.org/en/stable/classes/class_json.html
# handle file path -> only filename
# .csm [compressed/crafted state machine] (.ccsm) | .cstate [c -> crafted] | .comst [compressed state] | .crast [crafted state]
func save(path: String) -> void:
	if not path:
		print("Could not save file to path: ", path)
		return
	if not path.ends_with(self.file_extension):
		path += self.file_extension
	if not self.last_save_path:
		self.last_save_path = path
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		print("Could not save file to path: ", path)
		print(err)
		return
	for layer in self.layers:
		var filename = "layer_" + str(layer.get_id()) + ".json"
		var data: String = layer.save()
		writer.start_file(filename)
		writer.write_file(data.to_utf8_buffer())
		writer.close_file()
	writer.close()
	
func select_file(title: String, is_saving: bool, callback: Callable = self.load_from_file):
	var window: FileDialog = FileDialog.new()
	window.access = FileDialog.ACCESS_FILESYSTEM 
	window.file_mode = FileDialog.FILE_MODE_SAVE_FILE if is_saving else FileDialog.FILE_MODE_OPEN_FILE
	window.use_native_dialog = true # Optional: uses OS native picker
	window.mode_overrides_title = false
	window.title = title
	window.add_filter("*" + self.file_extension, "Compressed State Machine", "application/x-zip-compressed")
	window.file_selected.connect(callback)
	self.add_child(window)
	window.popup_centered()
	window.size = Vector2(1024, 576)
	window.position = self.get_window().size / 2.0
	
func load_from_file(path):
	pass
#endregion

#region Init/Ready/Process/Close
func _init() -> void:
	pass

func _ready() -> void:
	get_window().close_requested.connect(self._on_close)
	self.top_menu = preload("res://top_menu.gd").new()
	self.spawnLayer()
	self.top_menu.get_add_layer_button().pressed.connect(self.spawnLayer)
	self.top_menu.get_add_node_button().pressed.connect(self.spawnNode)
	self.top_menu.get_layer_up_button().pressed.connect(self.switch_layer_up)
	self.top_menu.get_layer_down_button().pressed.connect(self.switch_layer_down)
	self.top_menu.get_save_button().pressed.connect(self.select_file.bind("Save state machine to file:", true, self.save))
	self.top_menu.get_load_button().pressed.connect(self.select_file.bind("Load saved state machine from file:", false))
	
func _on_close() -> void:
	self.save(self.last_save_path)
	print("Klose requested")
	for layer in self.layers:
		layer.close()
		self.remove_child(layer)
	queue_free()
#endregion

#region Layer/Node Handling
func spawnLayer() -> void:
	var layer = preload("res://layer.gd").new()
	layer.setBGColor(Color(randf(), randf(), randf(), 0.3))
	self.switch_layer(layer)

func switch_layer(layer: Layer) -> void:
	var is_switch: bool = false
	if self.activeGraphLayer:
		self.activeGraphLayer.set_active(false)
		self.activeGraphLayer.set_visibility_layer(11 - self.activeGraphLayer.get_id())
		self.activeGraphLayer.visible = false
		self.activeGraphLayer.disconnect_signals(self.top_menu)
		self.activeGraphLayer.save()
		is_switch = true
	self.activeGraphLayer = layer
	self.activeGraphLayer.visible = true
	self.activeGraphLayer.set_active(true)
	self.activeGraphLayer.setup_ui(self.top_menu, is_switch)
	if self.activeGraphLayer.get_id() == 0:
		self.activeGraphLayer.set_id(self.last_layer_num)
		self.last_layer_num += 1
		if self.last_layer_num > 10:
			self.top_menu.add_layer_button.disabled = true
	if self.activeGraphLayer not in self.layers:
		self.layers.append(self.activeGraphLayer)
	if self.activeGraphLayer not in self.get_children():
		self.add_child(self.activeGraphLayer)
	self.activeGraphLayer.set_size(get_window().size)
	self.activeGraphLayer.set_position(Vector2(0, 0))
	self.top_menu.set_layer_label_text(str(self.activeGraphLayer.get_id()))
	#self.queue_redraw()

func switch_layer_up() -> void:
	var curr_layer_num = self.activeGraphLayer.get_id()
	for layer in self.layers:
		if layer.get_id() == curr_layer_num + 1:
			self.switch_layer(layer)

func switch_layer_down() -> void:
	var curr_layer_num = self.activeGraphLayer.get_id()
	for layer in self.layers:
		if layer.get_id() == curr_layer_num - 1:
			self.switch_layer(layer)

func spawnNode() -> void:
	self.activeGraphLayer.add_node()
#endregion
