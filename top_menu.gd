class_name TopMenu extends Node2D
# TODO: implement rearrange function

var elements: Array[Node] = []
var zoom_label: Label = null
var rearrange_button: Button = null
var minimap_button: Button = null
var add_layer_button: Button = null
var add_node_button: Button = null
var layer_up_button: Button = null
var layer_down_button: Button = null
var layer_label: Label = null
var save_button: Button = null
var load_button: Button = null
var settings_button: Button = null

#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _init() -> void:
	self.zoom_label = Label.new()
	self.zoom_label.text = "init"
	self.zoom_label.tooltip_text = "This displays the zoom level"

	self.rearrange_button = Button.new()
	self.rearrange_button.icon = preload("res://icons/Godot/GridLayout.svg")
	self.rearrange_button.tooltip_text = "Rearrange Nodes"

	self.minimap_button = Button.new()
	self.minimap_button.icon = preload("res://icons/Godot/GridMinimap.svg")
	self.minimap_button.tooltip_text = "Show/hide minimap"

	self.add_layer_button = Button.new()
	self.add_layer_button.icon = preload("res://icons/add_layer.svg")
	self.add_layer_button.tooltip_text = "Add Layer (of complexity ;)"

	self.add_node_button = Button.new()
	self.add_node_button.icon = preload("res://icons/add_node.svg")
	self.add_node_button.tooltip_text = "Add Node"

	self.layer_up_button = Button.new()
	self.layer_up_button.tooltip_text = "Go 1 Layer up"
	self.layer_up_button.icon = preload("res://icons/layer_up.svg")

	self.layer_label = Label.new()
	self.layer_label.text = "0"

	self.layer_down_button = Button.new()
	self.layer_down_button.tooltip_text = "Go 1 Layer down"
	self.layer_down_button.icon = preload("res://icons/layer_down.svg")
	
	self.save_button = Button.new()
	self.save_button.icon = preload("res://icons/save.svg")
	self.save_button.tooltip_text = "Save"
	
	self.load_button = Button.new()
	self.load_button.icon = preload("res://icons/load.svg")
	self.load_button.tooltip_text = "Load"
	
	self.settings_button = Button.new()
	self.settings_button.icon = preload("res://icons/settings.svg")
	self.settings_button.tooltip_text = "Seddings"

	# Element Order: Load, Save and Settings
	self.elements.append(self.load_button)
	self.elements.append(self.save_button)
	self.elements.append(self.settings_button)
	self.elements.append(VSeparator.new())
	# Element Order: Mini and Map
	self.elements.append(self.zoom_label)
	self.elements.append(self.minimap_button)
	self.elements.append(VSeparator.new())
	# Element Order: Layers
	self.elements.append(self.add_layer_button)
	self.elements.append(self.layer_up_button)
	self.elements.append(self.layer_label)
	self.elements.append(self.layer_down_button)
	self.elements.append(VSeparator.new())
	# Element Order: Nodes
	self.elements.append(self.rearrange_button)
	self.elements.append(self.add_node_button)

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

func get_layer_up_button() -> Button:
	return self.layer_up_button

func get_save_button() -> Button:
	return self.save_button

func get_load_button() -> Button:
	return self.load_button

func get_settings_button() -> Button:
	return self.settings_button

func get_layer_down_button() -> Button:
	return self.layer_down_button

func set_layer_label_text(text: String) -> void:
	self.layer_label.text = text

func get_elements() -> Array[Node]:
	return self.elements
#endregion

#region ZoomLabel
func _update_zoom_label(zoom: float) -> void:
	#print("Zoom Signal in TopMenu")
	var zoom_text = "Zoom " + str(int(zoom * 100)) + "%"
	self.zoom_label.set_text(zoom_text)
#endregion
