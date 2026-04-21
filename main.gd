class_name MainWindow extends Node2D
# TODO: add handling switching layers

var activeGraphEdit: CustomGraphEdit = null
var curr_visibility_layer_slots = 10 # only needed if previous layer is interactable
var top_menu: TopMenu = null
var layers: Array[CustomGraphEdit] = []
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
	self.top_menu.get_add_layer_button().pressed.connect(spawnLayer)
	self.top_menu.get_add_node_button().pressed.connect(spawnNode)
	
func _on_close() -> void:
	# TODO: save layer data
	for layer in self.layers:
		layer.close()
		self.remove_child(layer)
	queue_free()
#endregion

#region Layer/Node Handling
func spawnLayer() -> void:
	var size = get_window().size
	var pos = Vector2(0, 0)
	if activeGraphEdit:
		self.activeGraphEdit.set_active(false)
		#if self.curr_visibility_layer_slots < 3:
			#activeGraphEdit.set_visibility_layer_bit(self.curr_visibility_layer_slots, true)
			#self.curr_visibility_layer_slots -= 1
		#else:
			## TODO: emit warning 
			#pass
		self.activeGraphEdit.visible = false
		size = activeGraphEdit.size
		pos = activeGraphEdit.position
		self.activeGraphEdit.save()
		self.activeGraphEdit.close()
	self.activeGraphEdit = preload("res://graph_edit.gd").new()
	self.add_child(activeGraphEdit)
	self.activeGraphEdit.set_active(true)
	self.activeGraphEdit.setBGColor(Color(randf(), randf(), randf(), 0))
	self.activeGraphEdit.set_size(size)
	self.activeGraphEdit.set_position(pos)
	self.activeGraphEdit.visible = true
	self.activeGraphEdit.setup_ui(self.top_menu)
	self.layers.append(self.activeGraphEdit)

func spawnNode() -> void:
	self.activeGraphEdit.add_node()
#endregion
