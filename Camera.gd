extends Camera
onready var camera = get_node(".")
export var speed = 0.1;

func _process(delta):
	if Input.is_action_pressed("camera_backward"):
		camera.translation += Vector3(0.0,0.0,speed);
	elif Input.is_action_pressed("camera_forward"):
		camera.translation -= Vector3(0.0,0.0,speed);
	if Input.is_action_pressed("camera_left"):
		camera.translation -= Vector3(speed,0.0,0.0);
	elif Input.is_action_pressed("camera_right"):
		camera.translation += Vector3(speed,0.0,0.0);
