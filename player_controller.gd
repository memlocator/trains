extends Node3D
@export var speed = 14

var target_velocity = Vector3.ZERO
@onready var RailPath = $"../RailPath" as Path3D

var CurveUtil = preload("res://CurveUtil.gd")

var dragging = false
var valid_placement = false
var start_drag = Vector3.ZERO
var dist = 16
var curve_tightness = 1
var tightness_increment = 0.4

var debug_points = []
var rail_curves = []

func _get_mouse_world_pos():
	var cam = get_node("Camera3D")
	var mousepos = get_viewport().get_mouse_position()
	
	var space_state = get_world_3d().direct_space_state
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	if result and result.position:
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
	
	return mesh

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			curve_tightness -= tightness_increment
			curve_tightness = max(curve_tightness, 0)
			curve_tightness = min(curve_tightness, 16)
			
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			curve_tightness += tightness_increment
			curve_tightness = max(curve_tightness, 0)
			curve_tightness = min(curve_tightness, 16)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_world_pos = _get_mouse_world_pos()
			if mouse_world_pos != null:
				if event.pressed:
					last_curve_transform = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), false)
					last_forward = last_curve_transform.basis.z
					dragging = true
					start_drag = _get_mouse_world_pos()
					curve_tightness = 1
					
				if !event.pressed and valid_placement: #mouse btn released
					dragging = false
					for item in debug_points:
						item.queue_free()
					debug_points.clear()
					
					#RailPath.curve = CurveUtil.append(RailPath.curve, preview_curve)
					rail_curves.append(preview_curve)
					RailPath.generate_rails(preview_curve)
					RailPath.generate_sleepers(preview_curve)

						

func validate_curve(target_curve: Curve3D, lim: float) -> bool:
	var valid = true
	var points = []
	for i in range(3):
		var point_pos = target_curve.sample_baked((float(i)/target_curve.get_baked_length())*target_curve.get_baked_length())
		points.append(point_pos)

	
	for point_idx in points.size():
		if point_idx == 0 or point_idx == points.size()-1:
			continue
		var prev_point = points[point_idx-1]
		var point = points[point_idx]
		var next_point = points[point_idx+1]
		
		var prev_to_point = (point - prev_point).normalized()
		var point_to_next = (next_point - point).normalized()
		var dot_prod = point_to_next.dot(prev_to_point)
		if dot_prod < lim:
			valid = false
			break
		
	
	return valid
	

var preview_curve = Curve3D.new()
func preview_placement():
	preview_curve = Curve3D.new()
	valid_placement = true
	for item in debug_points:
		item.queue_free()
	debug_points.clear()
	
	preview_curve.clear_points()
	preview_curve.add_point(rail_curves[-1].get_point_position(rail_curves[-1].point_count-1))
	var pos = _get_mouse_world_pos()
	if pos:
		var mouse_world = RailPath.to_local(pos)
		preview_curve.add_point(mouse_world)
		
		
		var prev = rail_curves[-1].get_point_position(rail_curves[-1].point_count-1)#preview_curve.get_point_position(preview_curve.point_count-2)
		var curr = preview_curve.get_point_position(preview_curve.point_count-1)
		
		#the 'forward' vec of the last piece of the curve
		var vec =  (rail_curves[-1].sample_baked(rail_curves[-1].get_baked_length()-0.1, false) - rail_curves[-1].sample_baked(rail_curves[-1].get_baked_length() - 0.2, false)).normalized() 
		
		#control point calcs
		#curr dot forward
		var dot_prod = vec.dot((prev-curr).normalized())#prev.dot(curr)
		#lets get compare to the right vec to see which side
		var right_vec = rail_curves[-1].sample_baked_with_rotation(rail_curves[-1].get_baked_length()-0.1, false).basis.x
		var dot_right_prod = right_vec.dot((prev-curr).normalized())
		
		var signed_dot = dot_prod*dot_right_prod
		dist = dot_prod*dot_right_prod*-preview_curve.get_baked_length()
		
		var out_point = vec*abs(dist) + vec*(1-dot_prod)*-(curve_tightness/4)*dot_prod
		var in_point = right_vec*dist - vec*curve_tightness*-dot_prod#.lerp(-out_point*(dist/10), 0.5)#(prev-curr).lerp(out_point, dist/10)
		##control point calcs complete
		
		debug_points.append(_debug_point(rail_curves[-1].sample_baked(rail_curves[-1].get_baked_length() - 0.2, false)))
		debug_points.append(_debug_point(rail_curves[-1].sample_baked(rail_curves[-1].get_baked_length() - 0.1, false)))
		
		out_point = Vector3(out_point.x, 0, out_point.z)
		in_point = Vector3(in_point.x, 0, in_point.z)
		#if dot_prod < 0 and dot_prod < -0.3:
		preview_curve.set_point_out(preview_curve.point_count-2, out_point)
		preview_curve.set_point_in(preview_curve.point_count-1, in_point)
		
		valid_placement = (validate_curve(preview_curve, 0.85) and dot_prod < 0)
		if valid_placement:
			debug_points.append(_debug_point(curr + in_point))
			debug_points.append(_debug_point(prev + out_point))
			
			for i in range(50):
				var point_transform = preview_curve.sample_baked((float(i)/preview_curve.get_baked_length())*preview_curve.get_baked_length())
				var m = _debug_point(point_transform)
				debug_points.append(m)
		#else:
			#valid_placement = false

func _process(_delta):
	if dragging:
		preview_placement()
		
		
func _ready():
	set_process(true)
	rail_curves.append(RailPath.curve)
	rail_curves.append(rail_curves[-1])
	RailPath.generate_rails(rail_curves[-1])
	RailPath.generate_sleepers(rail_curves[-1])
		
		
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
	
