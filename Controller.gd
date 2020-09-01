extends Spatial
onready var camera = get_node("Camera")
#onready var islandMesh = get_node("IslandMesh").get_mesh()
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
	
	#if Input.is_action_pressed("noise_movement"):
	#	islandMesh.material.set_shader_param("offset",islandMesh.material.get_shader_param("offset")+Vector3(movement.x*-0.1,movement.z*-0.1,0.0))
	#else:
	#	camera.translation += movement;
	
	camera.translation += movement;
	

		
func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		event as InputEventMouseButton
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					camera.translation += Vector3(0.0,speed*10,0.0);
					#islandMesh.material.set_shader_param("offset",islandMesh.material.get_shader_param("offset")+Vector3(0.0,0.0,0.25))
				BUTTON_WHEEL_DOWN:
					camera.translation -= Vector3(0.0,speed*10,0.0);
					#islandMesh.material.set_shader_param("offset",islandMesh.material.get_shader_param("offset")-Vector3(0.0,0.0,0.25))
