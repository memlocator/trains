extends Node3D
@export var speed = 14

var target_velocity = Vector3.ZERO
@onready var RailPath = $"../RailPath" as Path3D

var dragging = false

func _get_mouse_world_pos():
	var cam = get_node("Camera3D")
	var mousepos = get_viewport().get_mouse_position()
	
	var space_state = get_world_3d().direct_space_state
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	if result.position:
		return result.position
	else:
		return null

var last_curve_transform = Transform3D()
var last_forward = Vector3.ZERO

func _debug_point(pos):
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	get_tree().get_root().add_child(mesh)
	mesh.transform.origin = pos
	mesh.scale = Vector3(0.2, 0.2, 0.2)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_world_pos = _get_mouse_world_pos()
			if mouse_world_pos:
				var geo_tool = Geometry2D
				
				var pos = RailPath.to_local(mouse_world_pos)
				
				if event.pressed:
					last_curve_transform = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true)
					last_forward = last_curve_transform.basis.z
					dragging = true
					
				if !event.pressed: #mouse btn released
					dragging = false
					
					var old_forward = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true).basis.z
					var old_pos = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true).origin
					var dot = (mouse_world_pos - old_pos).normalized().dot(old_forward)
					if dot < -0.5:
						RailPath.curve.add_point(pos)
						var prev_prev = RailPath.curve.get_point_position(RailPath.curve.point_count-3)
						var prev = RailPath.curve.get_point_position(RailPath.curve.point_count-2)
						var curr = RailPath.curve.get_point_position(RailPath.curve.point_count-1)
						
						var min_dist = Vector3(prev - curr).length()
						var control_line = Vector3(prev_prev - curr).normalized()
						var out_point = control_line * -(min_dist/2)#-4
						var in_point = control_line * (min_dist/2)#4
						
						#_debug_point(prev + out_point)
						#_debug_point(prev + in_point)
						RailPath.curve.set_point_in(RailPath.curve.point_count-2, in_point)
						RailPath.curve.set_point_out(RailPath.curve.point_count-2, out_point)
						
						RailPath.generate_rails()
						RailPath.generate_sleepers()

func preview_placement():
	pass #TODO

func _process(delta):
	if dragging:
		preview_placement()
		#print("dragging ", dragging)
		
		
func _ready():
	set_process(true)
		
		
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
	
