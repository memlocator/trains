extends Node3D
@export var speed = 14

var target_velocity = Vector3.ZERO
@onready var RailPath = $"../RailPath" as Path3D


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var cam = get_node("Camera3D")
			var mousepos = get_viewport().get_mouse_position()
			
			var space_state = get_world_3d().direct_space_state
			var origin = cam.project_ray_origin(mousepos)
			var end = origin + cam.project_ray_normal(mousepos) * 100
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			query.collide_with_areas = true
			
			var result = space_state.intersect_ray(query)
			if result.position:
				#print(result.position)
				var pos = RailPath.to_local(result.position)
				RailPath.curve.add_point(pos)
				RailPath.generate_rails()
				RailPath.generate_sleepers()
			else:
				print(result)
		

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	var velocity = direction*speed*delta
	transform = transform.translated(velocity)
	
