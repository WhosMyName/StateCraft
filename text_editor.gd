class_name TextEditorTile extends BaseTile

var editor: CodeEdit = null
var delete_node_button: Button = null
#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.editor = CodeEdit.new()
	self.editor.set_stretch_ratio(9)
	self.editor.size = Vector2(200, 200)
	self.editor.custom_minimum_size = self.editor.size
	self.editor.gutters_draw_line_numbers = true
	self.editor.delimiter_comments.append_array(["//", "#"]) # TODO: fix commentsnot working
	
	self.delete_node_button = Button.new()
	self.delete_node_button.icon = preload("res://icons/trash.svg")
	self.delete_node_button.tooltip_text = "Click to delete this tile"
	
	var vbox = VBoxContainer.new()
	var button_hbox = HBoxContainer.new()
	button_hbox.add_spacer(false)
	button_hbox.add_child(self.delete_node_button)
	
	vbox.add_child(HSeparator.new())
	vbox.add_child(self.editor)
	vbox.add_child(button_hbox)
	self.add_child(vbox)
	
	self.delete_node_button.pressed.connect(self.close)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func close() -> void:
	disconnect_signal(self.delete_node_button.pressed)
	self.get_parent().remove_child(self)
	queue_free()
#endregion


#region Save/Load Data
func save(data: Dictionary = {}) -> Dictionary:
	data = {
		"name": "TextEditorTile",
		"text": self.editor.text
	}
	return data

func load_data(data: Dictionary) -> void:
	self.editor.text = data["text"]
#endregion
