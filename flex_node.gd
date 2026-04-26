class_name FlexNode extends GraphNode
# TODO: make every element it's own class
# TODO: make textedit the whole ting
# TODO: handle resizing generally (both tiles and node)
# TODO: use hseparator as resize bar

var add_button_container: VBoxContainer = null
var add_elem_button: MenuButton = null
var color_left = Color(0,1,0)
var color_right = Color(1,0,0)
var tiles: Array[BaseTile] = []


#region Init/Ready/Process/Close
func _init() -> void:
	pass

func _ready() -> void:
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
func load_from_json(data: Dictionary) -> void:
	pass
#endregion

#region (File-)Editor Windows
func open_edit_window(editor, content, content_size: Vector2) -> void:
	var window: Window = Window.new()
	editor.size = content_size
	editor.text = content.text
	window.close_requested.connect(self.close_edit_text_window.bind(window, editor, content))
	window.add_child(editor)
	self.get_parent().add_child(window)
	window.size = content_size
	window.position = self.get_parent_area_size() / 2
	window.size_changed.connect(func(): editor.size = window.size)

func close_edit_text_window(window: Window, editor: CodeEdit, content: RichTextLabel) -> void:
	content.text = editor.text
	window.hide()
	window.remove_child(editor)
	self.get_parent().remove_child(window)


#endregion

#region Node Element Handling
func make_generic_box(elem_type, editor_type, content_size:  Vector2) -> void:
	var vbox = VBoxContainer.new()
	var content = elem_type.new()
	var edit_button = Button.new()
	var editor = null
	if content is Control:
		content.set_stretch_ratio(9)
		content.size = content_size
		content.custom_minimum_size = content_size
	if content is RichTextLabel: # handling text fields
		editor = editor_type.new()
		editor.gutters_draw_line_numbers = true
		editor.delimiter_comments.append_array(["//", "#"]) # TODO: fix commentsnot working
		editor.text_changed.connect(func(): content.text = editor.text)
	elif content is TextureRect: # IMAGES
		editor = editor_type
		content.texture = preload("res://icons/clock.svg")
		content.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		content.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	edit_button.pressed.connect(self.open_edit_window.bind(editor, content, Vector2(500, 500)))		
	vbox.add_child(HSeparator.new())
	vbox.add_child(content)
	edit_button.icon = preload("res://icons/Godot/Edit.svg")
	var hbox = HBoxContainer.new()
	# TODO: add delete box button
	hbox.add_child(edit_button)
	hbox.add_spacer(true).set_stretch_ratio(8)
	vbox.add_child(hbox)
	self.add_child(vbox)
	# self.get_child_count() - 2, because self.add_button_container and reordering from below
	self.set_slot(self.get_child_count() - 2, true, 0, self.color_left, true, 0, self.color_right)
	self.move_child(self.add_button_container, self.get_child_count())

func smol_box(tile: BaseTile, elem_size):
	self.tiles.append(tile)
	tile.size = elem_size
	tile.custom_minimum_size = elem_size
	self.add_child(tile)
	# self.get_child_count() - 2, because self.add_button_container and reordering from below
	self.set_slot(self.get_child_count() - 2, true, 0, self.color_left, true, 0, self.color_right)
	self.move_child(self.add_button_container, self.get_child_count() - 1)

func add_elem(id) -> void:
	# dynamically load element types (plaintext, markdown, video, audio, image)
	if id == 0: # PlainText/RichText/BBCode
		self.make_generic_box(RichTextLabel, CodeEdit, Vector2(150, 150))
	elif id == 1: # Markdown
		self.make_generic_box(RichTextLabel, CodeEdit, Vector2(150, 150))
	elif id == 2: # Image
		self.smol_box(ImageViewerTile.new(), Vector2(200, 240))
	elif id == 3: # Saund
		self.smol_box(AudioPlayerTile.new(), Vector2(185, 120))
	elif id == 4: # WHOOOP, OK GARMIN, FIDEO SPEICHERN!
		# TODO: implement https://github.com/VoylinsGamedevJourney/gde_gozen
		self.make_generic_box(VideoStreamPlayer, FileDialog, Vector2(400, 400))
	else:
		pass
	self.size = Vector2(0, 0)

#endregion
