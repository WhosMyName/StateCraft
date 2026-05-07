class_name VideoPlayerTile extends BaseTile
# TODO: implement https://github.com/VoylinsGamedevJourney/gde_gozen

var player: VideoPlayback = null
var title_label: Label = null
var volume_label: Label = null
var play_pause_button: Button = null
var seeker: HSlider = null
var volume_slider: HSlider = null
var video_pos: int = 0
var curr_video_name: String = "null"
var seeker_timer: float = 0
var video_len: float = 0
var select_file_button: Button = null
var delete_node_button: Button = null
var file_path = ""

#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.player = VideoPlayback.new()
	self.player.custom_minimum_size = Vector2(300, 300)
	self.player.size = Vector2(300, 300)
	
	var vbox = VBoxContainer.new()
	var upper_hbox = HBoxContainer.new()
	var lower_hbox = HBoxContainer.new()
	var button_hbox = HBoxContainer.new()
	self.title_label = Label.new()
	self.title_label.text = "Waiting for files ;)"
	self.volume_label = Label.new()
	self.volume_label.text = "50%"
	self.volume_label.reset_size()
	self.volume_label.size = self.volume_label.size * Vector2(1.3, 0)
	self.volume_label.custom_minimum_size = self.volume_label.size
	self.play_pause_button = Button.new()
	self.play_pause_button.icon = preload("res://icons/play_pause.svg")
	self.seeker = HSlider.new()
	self.seeker.custom_minimum_size = Vector2(160, 20)
	#self.seeker.set_stretch_ratio(9)
	self.volume_slider = HSlider.new()
	self.volume_slider.custom_minimum_size = Vector2(120, 25)
	self.volume_slider.value = 50.0
	#self.volume_slider.set_stretch_ratio(9)
	var fake_volume_label = Button.new()
	fake_volume_label.icon = preload("res://icons/sound.svg")
	fake_volume_label.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 1))
	fake_volume_label.disabled = true
	self.select_file_button = Button.new()
	self.select_file_button.icon = preload("res://icons/Godot/Edit.svg")
	self.select_file_button.tooltip_text = "Click to select a file"
	self.delete_node_button = Button.new()
	self.delete_node_button.icon = preload("res://icons/trash.svg")
	self.delete_node_button.tooltip_text = "Click to delete this tile"
	# Layout
	upper_hbox.add_child(self.play_pause_button)
	upper_hbox.add_child(self.seeker)
	
	lower_hbox.add_child(fake_volume_label)
	lower_hbox.add_child(self.volume_slider)
	lower_hbox.add_child(self.volume_label)
	
	button_hbox.add_child(self.select_file_button)
	button_hbox.add_spacer(false)
	button_hbox.add_child(self.delete_node_button)
	
	vbox.add_child(HSeparator.new())
	vbox.add_child(self.title_label)
	vbox.add_child(self.player)
	vbox.add_child(upper_hbox)
	vbox.add_child(lower_hbox)
	vbox.add_child(button_hbox)
	# Signals
	self.play_pause_button.pressed.connect(self._play_pause_video)
	self.seeker.drag_ended.connect(self._seek)
	self.volume_slider.drag_ended.connect(self._volume)
	self.delete_node_button.pressed.connect(self.close)
	self.select_file_button.pressed.connect(self.select_file.bind("Open Audio:"))
	# finalize
	self.add_child(vbox)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func close() -> void:
	disconnect_signal(self.delete_node_button.pressed)
	disconnect_signal(self.select_file_button.pressed)
	self.get_parent().remove_child(self)
	queue_free()
#endregion


func load_from_path(path) -> void:
	if not path:
		return
	self.player.set_video_path(path)
	self.file_path = path
	self.curr_video_name = path.rsplit("/", false, 1).get(1)
	self.title_label.text = "Loaded: " + self.curr_video_name
	self.video_len = self.player.get_video_length_float() # get track len
	self.seeker.value = 0
	print("VidLen: ", self.video_len)
	self.video_pos = 0
	print("Loading video from ", path)

func _play_pause_video() -> void:
	if self.player.path:
		if self.player.is_playing:
			self.player.pause()
			self.title_label.text = "Paused..."
			self.play_pause_button.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 0.4))
		else:
			self.title_label.text = "Playing: " + self.curr_video_name
			self.player.play()
			self.play_pause_button.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 1))

func _seek(value_changed) -> void:
	if value_changed:
		self.video_pos = int(self.seeker.get_as_ratio() * self.player.get_video_frame_count())
		self.player.seek_frame(self.video_pos)
		print("PlaybPos: ", self.player.get_current_playback_position_float())

func _volume(value_changed: bool) -> void:
	if value_changed:
		self.player.audio_player.volume_linear = self.volume_slider.value / 100
		self.volume_label.text = str(int(self.volume_slider.value)) + "%"
