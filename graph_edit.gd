class_name CustomGraphEdit extends GraphEdit
# TODO: fix re-size scaling
# TODO: rename to layer

signal zoom_changed(zoom: float)
var _old_zoom: float = 0

@export var is_active = true
@export var _id: int = 0
@export var bgColor = Color(0, 0.5, 0, 0.3)
@export var disable_zoom_label = false
var graph_nodes_list: Array[FlexNode] = []
var bgStyleBox = StyleBoxFlat.new()

#region Init/Ready/Process/Close
func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load_from_json()
	self.right_disconnects = true
	self.zoom_min = 0.1
	self.zoom_max = 4
	self.zoom_step = 1.25 # Err:  Condition "p_scroll_zoom_factor <= 1.0" is true.
	# above is kinda irrelevant as the steps drift
	self.connection_request.connect(self._on_connection_request)
	self.disconnection_request.connect(self._on_disconnection_request)
	self.delete_nodes_request.connect(self._on_delete_nodes_request)
	 # TODO: maybe implement this
	#self.copy_nodes_request
	#self.paste_nodes_request
	#self.cut_nodes_request
	#self.duplicate_nodes_request
	#self.duplicate_nodes_request
	self._setBGColor()
	
	self.get_menu_hbox().pivot_offset = Vector2(0, 0)
	# get_window().size_changed.connect(self._on_window_resized)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func close() -> void:
	# TODO: save to file
	print("Closing GraphEdit: ", self)
	for node in self.graph_nodes_list:
		node.close()
		self.remove_child(node)
#endregion

#region Getter/Setter
func set_active(active: bool) -> void:
	self.is_active = active

func get_active() -> bool:
	return self.is_active

func set_id(id: int) -> void:
	self._id = id

func get_id() -> int:
	return self._id

func add_node() -> void:
	var node: FlexNode = preload("res://flex_node.gd").new()
	# TODO: fix node positioning
	node.position = self.get_viewport_rect().size / 2
	print(node.position)
	self.add_child(node)
	self.graph_nodes_list.append(node)
	
#endregion

#region Load/Save Data
func load_from_json(data: Dictionary) -> void:
	# TODO: Load is_active
	# TODO: Load id
	# TODO: Load bgColor
	# TODO: Create Nodes from NodeList
	# TODO: load button defaults
	pass

func save() -> JSON:
	# TODO: define this
	return JSON.new()

#endregion

#region UI Handling/Setup
func setup_ui(menu:TopMenu) -> void:
	# can't override that damned self.get_menu_hbox() *grrrr*
	# connecc the signals
	self.zoom_changed.connect(menu._update_zoom_label)
	self.zoom_changed.emit(self.zoom)
	menu.get_minimap_button().pressed.connect(func(): self.minimap_enabled = !self.minimap_enabled)
	menu.get_rearrange_button_button().pressed.connect(self.arrange_nodes)
	# menu "refresh"
	for child in self.get_menu_hbox().get_children():
		self.get_menu_hbox().remove_child.call_deferred(child)
	for node in menu.get_elements():
		if node.get_parent():
			node.reparent(self.get_menu_hbox())
		else:
			self.get_menu_hbox().add_child.call_deferred(node)
	self.show_zoom_label = true
	self.minimap_enabled = false
#endregion

#region Window Handling
func _on_window_resized() -> void:
	# TODO: delayed until pfffffffffffffffffffffffffft
	print("HboxSize", self.get_menu_hbox().size)
	#self.get_menu_hbox().minimum_size = self.get_menu_hbox().custom_minimum_size
	print("HboxMinSize", self.get_menu_hbox().get_minimum_size())
	print("HboxCMinSize", self.menu_hbox)
#endregion

#region Node Connection Handling

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	self.connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	self.disconnect_node(from_node, from_port, to_node, to_port)

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for child in self.graph_nodes_list:
		if child.name in nodes:
			print("Deleting Node: ", child)
			child.close()
			self.remove_child(child)
			self.graph_nodes_list.erase(child)
#endregion

#region Coloring
func _setBGColor() -> void:
	self.bgStyleBox.bg_color = self.bgColor
	self.add_theme_stylebox_override("panel", bgStyleBox)

func setBGColor(color: Color) -> void:
	self.bgColor = color
	self._setBGColor()

func setBGColorPicker() -> void:
	# TODO: get Color via ColorPicker
	# setBGColor()
	pass
#endregion

#region Zoom Handling
func _check_zoom() -> void:
	if not is_equal_approx(self.zoom, self._old_zoom):
		self._old_zoom = self.zoom
		self.zoom_changed.emit(zoom)
		#print(self.zoom)
		#print(self.zoom_step)

func _gui_input(event) -> void:
	# Check if the event is a mouse button (scroll) or a touch gesture
	if event is InputEventMouseButton or event is InputEventMagnifyGesture:
		self._check_zoom.call_deferred()
#endregion
