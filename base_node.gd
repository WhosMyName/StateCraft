class_name BaseNode extends GraphNode

var _id = 0 # layer id
var nid = 0 # cross-layer node id
#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.nid = self.get_instance_id()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

func save(data: Dictionary = {}) -> Dictionary:
	data["id"] = self._id
	data["uuid"] = self.nid
	return data
	
func load_data(data: Dictionary) -> void:
	self._id = data["id"]
	self.nid = data["uuid"]
#endregion

#region Getter/Setter
func get_id() -> int:
	return self._id
	
func set_id(inid: int) -> void:
	self._id = inid

func get_nid() -> int:
	return self.nid
	
func set_nid(enid: int) -> void:
	self.nid = enid
#endregion
