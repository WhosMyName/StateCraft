class_name Layer extends GraphEdit
# TODO: fix top menu re-size scaling (keep size, until 1/2 original size then scale)
# see _on_window_resized()
# TODO: fix on node click centering
signal zoom_changed(zoom: float)
var _old_zoom: float = 0

var is_active = true
var _id: int = 0
var bgColor = Color(0, 0.5, 0, 0.3)
var graph_nodes_list: Array[FlexNode] = []
var bgStyleBox: StyleBoxFlat = StyleBoxFlat.new()
var menu_box_size: Vector2 = Vector2.ZERO
var node_number: = 0

#region Init/Ready/Process/Close
func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.right_disconnects = true
	self.zoom_min = 0.1
	self.zoom_max = 4
	self.zoom_step = 1.25 # Err:  Condition "p_scroll_zoom_factor <= 1.0" is true.
	# above is kinda irrelevant as the steps drift
	self.connection_request.connect(self._on_connection_request)
	self.disconnection_request.connect(self._on_disconnection_request)
	self.delete_nodes_request.connect(self._on_delete_nodes_request)
	#self.node_selected.connect(self.center_on_node)
	# TODO: maybe implement this
	#self.copy_nodes_request
	#self.paste_nodes_request
	#self.cut_nodes_request
	#self.duplicate_nodes_request
	#self.duplicate_nodes_request
	self.get_menu_hbox().pivot_offset = Vector2(0, 0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print("ScrollOffset", self.scroll_offset)
	pass
	
func close() -> void:
	print("Closing GraphEdit: ", self)
	for node in self.graph_nodes_list:
		if node:
			node.close()
			if node.get_parent() == self:
				self.remove_child(node)
	self.graph_nodes_list.clear()

func disconnect_signals(menu: TopMenu) -> void:
	# disconnecc the signals
	if self.zoom_changed.is_connected(menu._update_zoom_label):
		self.zoom_changed.disconnect(menu._update_zoom_label)
	if menu.get_minimap_button().pressed.is_connected(self.toggle_minimp):
		menu.get_minimap_button().pressed.disconnect(self.toggle_minimp)
	if menu.get_rearrange_button_button().pressed.is_connected(self.arrange_nodes):
		menu.get_rearrange_button_button().pressed.disconnect(self.arrange_nodes)
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

func has_nodes() -> bool:
	return true if self.graph_nodes_list.size() > 0 else false
#endregion

#region Node Handling
func add_node() -> void:
	var node: FlexNode = preload("res://flex_node.gd").new()
	node.set_id(self.node_number)
	self.node_number += 1 # TODO: maybe add safer node num checking
	self.add_child(node)
	self.graph_nodes_list.append(node)
	node.position_offset = self.scroll_offset + (self.size / 2.0) - (node.size / 2)
	# TODO: check if another node is at this position and find a new one
	
func find_node_by_id(id: int) -> BaseNode:
	for node in self.graph_nodes_list:
		if node.get_id() == id:
			return node
	return null
	
func center_on_node(node) -> void:
	var new_scroll_offset = (node.position_offset + (node.size / 2.0)) - ((self.size / 2.0) / self.zoom)
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "scroll_offset", new_scroll_offset, 0.5).set_trans(Tween.TRANS_QUINT)
#endregion

#region Load/Save Data
func load_data(data: Dictionary) -> void:
	self.zoom = 0
	self._id = data["_id"]
	self.is_active = data["is_active"]
	self.setBGColor(JSON.to_native(data["bgColor"]))
	for node_data in data["nodes"]:
		var node: FlexNode = preload("res://flex_node.gd").new()
		self.add_child(node)
		self.graph_nodes_list.append(node)
		node.load_data(node_data)
		if node.get_id() > self.node_number:
			self.node_number = node.get_id()
	for connection in data["connections"]:
		connection["from_node"] = self.find_node_by_id(connection["from_node"]).name
		connection["to_node"] = self.find_node_by_id(connection["to_node"]).name
		self.connect_node(
			connection["from_node"], connection["from_port"],
			connection["to_node"], connection["to_port"]
		)
	self.zoom = data["zoom"]
	self._check_zoom()
	self.scroll_offset = JSON.to_native(data["scroll_offset"])

func save() -> String:
	self._old_zoom = self.zoom
	if not self.graph_nodes_list: # return null if there're no nodes
		return ""
	var data = {
		"_id": self._id,
		"is_active": self.is_active,
		"bgColor": JSON.from_native(self.bgColor),
		"zoom": self.zoom,
		"scroll_offset": JSON.from_native(self.scroll_offset),
		"nodes": [],
		"connections": [] 
	}
	self.zoom = 0
	for node in self.graph_nodes_list:
		data["nodes"].append(node.save())
	for connection in self.connections:
		connection["from_node"] = self.get_node(NodePath(connection["from_node"])).get_id()
		connection["to_node"] = self.get_node(NodePath(connection["to_node"])).get_id()
		data["connections"].append(connection)
	self.zoom = self._old_zoom
	return JSON.stringify(data, "\t")

#endregion

#region UI Handling/Setup
func setup_ui(top_menu:TopMenu, is_layer_switch:bool = false) -> void:
	# can't override that damned self.get_menu_hbox() *grrrr*
	# connecc the signals
	if not self.zoom_changed.is_connected(top_menu._update_zoom_label):
		self.zoom_changed.connect(top_menu._update_zoom_label)
	self.zoom_changed.emit(self.zoom)
	if not top_menu.get_minimap_button().pressed.is_connected(self.toggle_minimp):
		top_menu.get_minimap_button().pressed.connect(self.toggle_minimp)
	if not top_menu.get_rearrange_button_button().pressed.is_connected(self.arrange_nodes):
		top_menu.get_rearrange_button_button().pressed.connect(self.arrange_nodes)
	if not top_menu.get_add_node_button().pressed.is_connected(self.add_node):
		top_menu.get_add_node_button().pressed.connect(self.add_node)
	# menu_box "refresh"
	var menu_box = self.get_menu_hbox()
	if self.menu_box_size == Vector2.ZERO and menu_box.size != Vector2.ZERO and is_layer_switch:
		self.menu_box_size = menu_box.size
	menu_box.visible = false
	for child in menu_box.get_children():
		menu_box.remove_child(child)
	for node in top_menu.get_elements():
		if node.get_parent():
			node.reparent(menu_box)
		else:
			menu_box.add_child(node)
	self.show_zoom_label = true
	self.minimap_enabled = false

	if self.menu_box_size != Vector2.ZERO and is_layer_switch:
		menu_box.reset_size()
		menu_box.get_parent().custom_minimum_size = menu_box_size + Vector2(8, 4)
		menu_box.get_parent().reset_size()
	menu_box.visible = true
	
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

#region Minimapping
func toggle_minimp() -> void:
	self.minimap_enabled = !self.minimap_enabled
#endregion
