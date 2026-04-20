class_name AudioPlayer extends Control
# TODO fix volume slider positioning/access/grabbiness

var player: AudioStreamPlayer = null
var title_label: Label = null
var volume_label: Label = null
var play_pause_button: Button = null
var seeker: HSlider = null
var volume: HSlider = null
var audio_pos: float = 0.0
var curr_track_name: String = "null"
var seeker_timer: float = 0
var track_len: float = 0

#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vbox = VBoxContainer.new()
	var upper_hbox = HBoxContainer.new()
	var lower_hbox = HBoxContainer.new()
	self.title_label = Label.new()
	self.title_label.text = "Waiting for files ;)"
	self.volume_label = Label.new()
	self.volume_label.text = "50%"
	self.player = AudioStreamPlayer.new()
	self.player.set_volume_linear(0.66)
	self.play_pause_button = Button.new()
	self.play_pause_button.icon = preload("res://icons/play_pause.svg")
	self.seeker = HSlider.new()
	self.seeker.custom_minimum_size = Vector2(150, 20)
	self.seeker.set_stretch_ratio(9)
	self.volume = HSlider.new()
	self.volume.custom_minimum_size = Vector2(120, 25)
	self.volume.value = 50.0
	self.volume.set_stretch_ratio(8)
	var fake_volume_label = Button.new()
	fake_volume_label.icon = preload("res://icons/sound.svg")
	fake_volume_label.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 1))
	fake_volume_label.disabled = true
	# Layout
	upper_hbox.add_child(self.play_pause_button)
	upper_hbox.add_child(self.seeker)
	
	lower_hbox.add_child(fake_volume_label)
	lower_hbox.add_child(volume)
	lower_hbox.add_child(self.volume_label)
	
	vbox.add_child(self.title_label)
	vbox.add_child(upper_hbox)
	vbox.add_child(lower_hbox)
	# Signals
	self.play_pause_button.pressed.connect(self._play_pause_audio)
	self.seeker.drag_ended.connect(self._seek)
	self.volume.drag_ended.connect(self._volume)
	self.add_child(vbox)
	self.add_child(self.player, false, Node.INTERNAL_MODE_BACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.player.stream and self.player.playing:
		self.seeker_timer += delta
		if self.seeker_timer >= 1.0:
			self._slide_seeker()
			self.seeker_timer = 0.0
#endregion

#region Audio Loading
func load_from_file(path) -> void:
	self.player.stop()
	self.player.stream = AudioStreamMP3.load_from_file(path) if path.ends_with(".mp3") else AudioStreamOggVorbis.load_from_file(path)
	self.curr_track_name = path.rsplit("/", false, 1).get(1)
	self.title_label.text = "Loaded: " + self.curr_track_name
	self.track_len = self.player.stream.get_length() # get track len
	print("TrackLen: ", self.track_len)
	self.audio_pos = 0.0
	print("Loading audio from ", path)
#endregion

#region Play/Pause/Seek
func _play_pause_audio() -> void:
	#print("Playpausing")
	if self.player.stream:
		if self.player.playing:
			self.audio_pos = self.player.get_playback_position() + AudioServer.get_time_since_last_mix()
			self.player.stop()
			self.title_label.text = "Paused..."
		else:
			self.title_label.text = "Playing: " + self.curr_track_name
			self.player.play(self.audio_pos)

func _seek(value_changed) -> void:
	var playing = self.player.playing
	if value_changed:
		self.audio_pos = self.seeker.get_as_ratio() * self.track_len
		self.player.seek(self.audio_pos)
		print("PlaybPos: ", self.player.get_playback_position())
#endregion

#region Slider Handling
func _slide_seeker() -> void:
	print("PlaybPos: ", self.player.get_playback_position())
	var pos = (self.player.get_playback_position() / self.track_len) * 100 
	self.seeker.set_value_no_signal(pos)

func _volume(value_changed: bool) -> void:
	if value_changed:
		self.player.volume_linear = self.volume.value / 100
		self.volume_label.text = str(int(self.volume.value)) + "%"

#endregion
