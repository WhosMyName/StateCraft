class_name TopMenu extends Node2D
# TODO: implement layer display (disabled button?) 
# TODO: implement layer switching buttons 

var elements: Array[Node] = []
var zoom_label: Label = null
var rearrange_button: Button = null
var minimap_button: Button = null
var add_layer_button: Button = null
var add_node_button: Button = null

#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _init() -> void:
	self.zoom_label = Label.new()
	self.zoom_label.text = "init"
	self.zoom_label.tooltip_text = "This displays the zoom level"
	self.elements.append(zoom_label)
	
	self.rearrange_button = Button.new()
	self.rearrange_button.icon = preload("res://icons/Godot/GridLayout.svg")
	self.rearrange_button.tooltip_text = "Rearrange Nodes"
	self.elements.append(rearrange_button)
	
	self.minimap_button = Button.new()
	self.minimap_button.icon = preload("res://icons/Godot/GridMinimap.svg")
	self.minimap_button.tooltip_text = "Show/hide minimap"
	self.elements.append(minimap_button)
	
	self.add_layer_button = Button.new()
	self.add_layer_button.icon = preload("res://icons/add_layer.svg")
	self.add_layer_button.tooltip_text = "Add Layer (of complexity ;)"
	self.elements.append(add_layer_button)
	
	self.add_node_button = Button.new()
	self.add_node_button.icon = preload("res://icons/add_node.svg")
	self.add_node_button.tooltip_text = "Add Node"
	self.elements.append(add_node_button)
	#for node in self.elements:
		#self.add_child(node)

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
#endregion

#region Getter/Setter
func get_zoom_label() -> Label:
	return self.zoom_label

func get_add_layer_button() -> Button:
	return self.add_layer_button

func get_add_node_button() -> Button:
	return self.add_node_button
	
func get_minimap_button() -> Button:
	return self.minimap_button

func get_rearrange_button_button() -> Button:
	return self.rearrange_button

func get_elements() -> Array[Node]:
	return self.elements
#endregion

#region ZoomLabel
func _update_zoom_label(zoom: float) -> void:
	#print("Zoom Signal in TopMenu")
	var zoom_text = "Zoom " + str(int(zoom * 100)) + "%"
	self.zoom_label.set_text(zoom_text)
#endregion
