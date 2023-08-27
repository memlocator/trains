extends Node3D
@export var speed = 14

var target_velocity = Vector3.ZERO
@onready var RailPath = $"../RailPath" as Path3D

var dragging = false
var start_drag = Vector3.ZERO
var dist = 6

var debug_points = []


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
	
	return mesh

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			dist -= 0.05
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			dist += 0.05
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_world_pos = _get_mouse_world_pos()
			if mouse_world_pos:
				var geo_tool = Geometry2D
				
				var pos = RailPath.to_local(mouse_world_pos)
				
				if event.pressed:
					last_curve_transform = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true)
					last_forward = last_curve_transform.basis.z
					dragging = true
					start_drag = _get_mouse_world_pos()
					
				if !event.pressed: #mouse btn released
					dragging = false
					for item in debug_points:
						item.queue_free()
					debug_points.clear()
					
					var old_forward = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true).basis.z
					var old_pos = RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true).origin
					#var dot = (mouse_world_pos - old_pos).normalized().dot(old_forward)
					var dot = -1
					if dot < -0.5:
						#var out_point = -RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length()-1, true).basis.z*10#
						
						var vec = -(RailPath.curve.sample_baked(RailPath.curve.get_baked_length() - 5, true) - RailPath.curve.sample_baked(RailPath.curve.get_baked_length() - 4, true)).normalized()
						RailPath.curve.add_point(pos)
						var curr = RailPath.curve.get_point_position(RailPath.curve.point_count-1)
						var prev = RailPath.curve.get_point_position(RailPath.curve.point_count-2)
						var prev_prev = RailPath.curve.get_point_position(RailPath.curve.point_count-3)
						
						#not that for whatever reason we need to invert this
						var out_point = vec*4#-RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true).basis.z*10#*dist#(-(prev_prev - prev)).lerp(in_point, 0.5)#-preview_curve.get_point_in(preview_curve.point_count-1)*dist#-dist*RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length()-1, true).basis.z#-preview_curve.get_point_in(RailPath.curve.point_count-1)*dist#(prev-prev_prev).normalized()*dist#((curr - prev) - Vector3(curr.x, 0,0)).normalized()
						
						#var in_point = ((prev_prev - prev) - (prev - curr)).normalized()*-dist
						#var out_point = -RailPath.curve.get_point_in(RailPath.curve.point_count-1)*dist#(prev-prev_prev).normalized()*dist
						
						var in_point = (prev-curr).lerp(out_point, dist/10)#(curr-prev).normalized()#((prev_prev + prev) + (prev + curr)).normalized()#((prev_prev - prev) - (prev - curr)).normalized()*-4#*-dist

						
						#var in_point = ((prev_prev + prev) + (prev + curr)).normalized()
						
						_debug_point(prev + out_point)
						_debug_point(prev + in_point)
						RailPath.curve.set_point_in(RailPath.curve.point_count-1, in_point)
						RailPath.curve.set_point_in(RailPath.curve.point_count-2, -out_point*0.1)
						RailPath.curve.set_point_out(RailPath.curve.point_count-2, out_point)

						
						RailPath.generate_rails()
						RailPath.generate_sleepers()

var preview_curve = Curve3D.new()
func preview_placement():
	for item in debug_points:
		item.queue_free()
	debug_points.clear()
	
	preview_curve.clear_points()
	preview_curve.add_point(RailPath.curve.get_point_position(RailPath.curve.point_count-1))
	var mouse_world = RailPath.to_local(_get_mouse_world_pos())
	preview_curve.add_point(mouse_world)
	#preview_curve.set_point_in(preview_curve.point_count-1, RailPath.curve.get_point_in(RailPath.curve.point_count-1))
	#preview_curve.set_point_out(preview_curve.point_count-1, RailPath.curve.get_point_out(RailPath.curve.point_count-1))
	
	
	var prev_prev = RailPath.curve.get_point_position(RailPath.curve.point_count-2)
	var prev = RailPath.curve.get_point_position(RailPath.curve.point_count-1)#preview_curve.get_point_position(preview_curve.point_count-2)
	var curr = preview_curve.get_point_position(preview_curve.point_count-1)
	
	var vec = -(RailPath.curve.sample_baked(RailPath.curve.get_baked_length() - 3, true) - RailPath.curve.sample_baked(RailPath.curve.get_baked_length(), true)).normalized()
	var out_point = vec*4#-RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length(), true).basis.z*10#*dist#(-(prev_prev - prev)).lerp(in_point, 0.5)#-preview_curve.get_point_in(preview_curve.point_count-1)*dist#-dist*RailPath.curve.sample_baked_with_rotation(RailPath.curve.get_baked_length()-1, true).basis.z#-preview_curve.get_point_in(RailPath.curve.point_count-1)*dist#(prev-prev_prev).normalized()*dist#((curr - prev) - Vector3(curr.x, 0,0)).normalized()
	var in_point = (prev-curr).lerp(out_point, dist/10)#(curr-prev).normalized()#((prev_prev + prev) + (prev + curr)).normalized()#((prev_prev - prev) - (prev - curr)).normalized()*-4#*-dist


	debug_points.append(_debug_point(curr + in_point))
	debug_points.append(_debug_point(prev + out_point))
	
	preview_curve.set_point_out(preview_curve.point_count-2, out_point)
	preview_curve.set_point_in(preview_curve.point_count-1, in_point)
	for i in range(50):
		var transform = preview_curve.sample_baked((float(i)/preview_curve.get_baked_length())*preview_curve.get_baked_length())
		var m = _debug_point(transform)
		debug_points.append(m)

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
	
