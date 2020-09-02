extends Camera

export var speed = 0.25;

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
	
	#2d Rotation matrix
	var ang = fmod(self.rotation.y + (PI*2), (PI*2)) * -1;
	movement.x = movement.x * cos(ang) - movement.z * sin(ang);
	movement.z = movement.x * sin(ang) + movement.z * cos(ang);
	
	self.translation += movement;
	
	var rotation = Vector3(0.0,0.0,0.0);
	if Input.is_action_pressed("camera_rotate_left"):
		rotation += Vector3(0.0,speed/5,0.0);
	elif Input.is_action_pressed("camera_rotate_right"):
		rotation -= Vector3(0.0,speed/5,0.0);
	if Input.is_action_pressed("camera_rotate_up"):
		rotation += Vector3(speed/5,0.0,0.0);
	elif Input.is_action_pressed("camera_rotate_down"):
		rotation -= Vector3(speed/5,0.0,0.0);
	
	self.rotation += rotation;

		
func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		event as InputEventMouseButton
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					self.translation += Vector3(0.0,speed*10,0.0);
				BUTTON_WHEEL_DOWN:
					self.translation -= Vector3(0.0,speed*10,0.0);
