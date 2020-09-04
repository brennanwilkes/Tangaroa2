extends Camera

export var speed = 0.25;

func _process(delta):
	if Input.is_action_pressed("camera_forward") or Input.is_action_pressed("camera_backward") or Input.is_action_pressed("camera_left") or Input.is_action_pressed("camera_right"):
		var ang = -1;
		if Input.is_action_pressed("camera_forward"):
			ang = PI;		
		elif Input.is_action_pressed("camera_backward"):
			ang = PI*2;
		if Input.is_action_pressed("camera_left"):
			if ang==-1:
				ang = PI*3/2
			else:
				ang = (ang + PI*3/2)/2;
		elif Input.is_action_pressed("camera_right"):
			if ang==-1:
				ang = PI/2;
			else:
				ang = (fmod(ang,PI*2) + PI/2)/2;
			
		
		
		self.translation.x += speed * sin(self.rotation.y + ang);
		self.translation.z += speed * cos(self.rotation.y + ang);
	
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
