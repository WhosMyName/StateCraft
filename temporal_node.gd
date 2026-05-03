class_name TemporalNode extends BaseNode # links a node to a node on a different layer
# TODO: implement button
# TODO: implement signal(?) to main

var button: Button = null
var layers: Vector2i = Vector2()
var nodes: Array = []

#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.button = Button.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#endregion

#region Load/Save Data
func load_data(data: Dictionary) -> void:
	super.load_data(data)

func save(data: Dictionary = {}) -> Dictionary:
	# TODO: save connections (here?)
	# TODO: save files from tiles (and switch to internal path)
	return super.save(data)
#endregion
