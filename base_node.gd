class_name BaseNode extends GraphNode

var _id: int = 0 # layer id
var nid: String = "" # cross-layer node id
#region Init/Ready/Process/Close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.nid = UUID.v4()
	print("UUID: ", self.nid)

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
	
func compare_nid(other_nid: String) -> bool:
	return self.nid == other_nid
#endregion

#region Getter/Setter
func get_id() -> int:
	return self._id
	
func set_id(inid: int) -> void:
	self._id = inid

func get_nid() -> String:
	return self.nid
	
func set_nid(enid: String) -> void:
	self.nid = enid
#endregion
