extends Spatial

onready var isl = get_node("Island3D")

func _process(delta):
	if Input.is_action_pressed("anim_on"):
		isl.liveRefresh = true;
		isl.animate = true;
	if Input.is_action_pressed("anim_off"):
		isl.liveRefresh = false;
		isl.animate = false;
