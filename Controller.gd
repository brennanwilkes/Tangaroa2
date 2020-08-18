extends Spatial
onready var camera = get_node("Camera")
onready var heightmap = get_node("heightmap")
export var speed = 0.1;

func _process(delta):
	var movement = Vector3(0.0,0.0,0.0);
	if Input.is_action_pressed("camera_backward"):
		movement += Vector3(0.0,0.0,speed);
	elif Input.is_action_pressed("camera_forward"):
		movement -= Vector3(0.0,0.0,speed);
	if Input.is_action_pressed("camera_left"):
		movement -= Vector3(speed,0.0,0.0);
	elif Input.is_action_pressed("camera_right"):
		movement += Vector3(speed,0.0,0.0);
	
	if Input.is_action_pressed("noise_movement"):
		heightmap.material.set_shader_param("offset",heightmap.material.get_shader_param("offset")+Vector3(movement.x*-0.1,movement.z*-0.1,0.0))
	else:
		camera.translation += movement;
	

		
func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		event as InputEventMouseButton
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					heightmap.material.set_shader_param("offset",heightmap.material.get_shader_param("offset")+Vector3(0.0,0.0,0.25))
				BUTTON_WHEEL_DOWN:
					heightmap.material.set_shader_param("offset",heightmap.material.get_shader_param("offset")-Vector3(0.0,0.0,0.25))
