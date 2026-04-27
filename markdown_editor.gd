class_name MarkDownEditorTile extends BaseTile

var label: RichTextLabel = null
var editor: CodeEdit = null
var delete_node_button: Button = null
var edit_text_button: Button = null

#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.label = RichTextLabel.new()
	self.label.size = Vector2(200, 200)
	self.label.custom_minimum_size = self.label.size
	self.label.text = "Press the edit button below to start editing text.\nIt'll be rendered upon closing the editor window. :)"
	self.editor = CodeEdit.new()
	self.editor.set_stretch_ratio(9)
	self.editor.size = Vector2(200, 200)
	self.editor.custom_minimum_size = self.editor.size
	self.editor.gutters_draw_line_numbers = true
	self.editor.delimiter_comments.append_array(["//", "#"]) # TODO: fix commentsnot working
	
	self.edit_text_button = Button.new()
	self.edit_text_button.icon = preload("res://icons/Godot/Edit.svg")
	self.edit_text_button.tooltip_text = "Click to edit the text"
	self.delete_node_button = Button.new()
	self.delete_node_button.icon = preload("res://icons/trash.svg")
	self.delete_node_button.tooltip_text = "Click to delete this tile"
	
	var vbox = VBoxContainer.new()
	var button_hbox = HBoxContainer.new()
	button_hbox.add_child(self.edit_text_button)
	button_hbox.add_spacer(false)
	button_hbox.add_child(self.delete_node_button)
	
	vbox.add_child(HSeparator.new())
	vbox.add_child(self.label)
	vbox.add_child(button_hbox)
	self.add_child(vbox)
	
	self.edit_text_button.pressed.connect(self.open_edit_window)
	self.delete_node_button.pressed.connect(self.close)
	self.editor.text_changed.connect(func(): self.label.text = self.editor.text)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func close() -> void:
	disconnect_signal(self.edit_text_button.pressed)
	disconnect_signal(self.delete_node_button.pressed)
	disconnect_signal(self.editor.text_changed)
	self.get_parent().remove_child(self)
	queue_free()
#endregion


#region Window Handling
func open_edit_window() -> void:
	var window: Window = Window.new()
	window.close_requested.connect(self.close_edit_text_window.bind(window))
	window.add_child(self.editor)
	self.add_child(window)
	window.size = self.editor.size
	window.position = self.get_parent_area_size() / 2
	window.size_changed.connect(func(): self.editor.size = window.size)

func close_edit_text_window(window: Window) -> void:
	self.label.text = self.editor.text
	window.hide()
	window.remove_child(editor)
	self.remove_child(window)
#endregion
