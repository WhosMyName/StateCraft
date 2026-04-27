class_name MainWindow extends Node2D
# TODO: fix the leaky mem

var activeGraphLayer: Layer = null
var last_layer_num = 1 # only needed if previous layer is interactable
var top_menu: TopMenu = null
var layers: Array[Layer] = []
var hbox_size: Vector2 = Vector2()

#region Load/Save Data
# https://docs.godotengine.org/en/stable/classes/class_json.html
# handle file path -> only filename
# .csm [compressed/crafted state machine] (.ccsm) | .cstate [c -> crafted] | .comst [compressed state] | .crast [crrafted state]
func save() -> void:
	var writer = ZIPPacker.new()
	var err = writer.open("user://archive.zip")
	if err != OK:
		print(err)
		return
	for layer in self.layers:
		var data: JSON = layer.save()
		writer.start_file("hello.txt")
		writer.write_file("Hello World".to_utf8_buffer())
		writer.close_file()

	writer.close()
	for layer in self.layers:
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
	
func _on_close() -> void:
	# TODO: save layer data
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
