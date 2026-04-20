class_name FlexNode extends GraphNode

var add_button_container: VBoxContainer = null
var add_elem_button: MenuButton = null
var color_left = Color(0,1,0)
var color_right = Color(1,0,0)


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
func open_edit_window(editor, content, size: Vector2) -> void:
	if editor == FileDialog:
		var window: FileDialog = editor.new()
		window.access = FileDialog.ACCESS_FILESYSTEM
		window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		window.use_native_dialog = true # Optional: uses OS native picker
		window.mode_overrides_title = false
		window.title = "Open " + "Image" if content is TextureRect else "Audio" if content is AudioPlayer else "Video"
		window.file_selected.connect(self.close_file_access_window.bind(content))
		self.get_parent().add_child(window)
		window.popup_centered()
		window.size = size
		window.position = self.get_parent_area_size() / 2
	else:
		var window: Window = Window.new()
		editor.size = size
		editor.text = content.text
		window.close_requested.connect(self.close_edit_text_window.bind(window, editor, content))
		window.add_child(editor)
		self.get_parent().add_child(window)
		window.size = size
		window.position = self.get_parent_area_size() / 2
		window.size_changed.connect(func(): editor.size = window.size)
	
func close_edit_text_window(window: Window, editor: CodeEdit, content: RichTextLabel) -> void:
	content.text = editor.text
	window.hide()
	window.remove_child(editor)
	self.get_parent().remove_child(window)

func close_file_access_window(path: String, content) -> void:
	if content is TextureRect:
		content.texture = load(path)
	elif content is AudioPlayer:
		content.load_from_file(path)
		print("Audio loaded:")
	else: # Fideo
		pass
	print(path)
#endregion

#region Node Element Handling
func make_generic_box(elem_type, editor_type, size:  Vector2) -> void:
	var vbox = VBoxContainer.new()
	var content = elem_type.new()
	var edit_button = Button.new()
	var editor = null
	if content is Control:
		content.set_stretch_ratio(9)
		content.size = size
		content.custom_minimum_size = size
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
	elif content is AudioPlayer: # AUDIO
		editor = editor_type
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


func add_elem(id) -> void:
	# dynamically load element types (plaintext, markdown, video, audio, image)
	if id == 0: # PlainText/RichText/BBCode
		self.make_generic_box(RichTextLabel, CodeEdit, Vector2(150, 150))
	elif id == 1: # Markdown
		self.make_generic_box(RichTextLabel, CodeEdit, Vector2(150, 150))
	elif id == 2: # Image
		self.make_generic_box(TextureRect, FileDialog, Vector2(200, 200))
	elif id == 3: # Saund
		self.make_generic_box(AudioPlayer, FileDialog, Vector2(220, 60))
	elif id == 4: # WHOOOP, OK GARMIN, FIDEO SPEICHERN!
		# TODO: implement https://github.com/VoylinsGamedevJourney/gde_gozen
		self.make_generic_box(VideoStreamPlayer, FileDialog, Vector2(400, 400))
	else:
		pass
	self.size = Vector2(0, 0)

#endregion
