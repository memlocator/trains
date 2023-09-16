extends Node


static func append(curve0: Curve3D, curve1: Curve3D) -> Curve3D:
	var trans = curve0.get_baked_points()[curve0.get_baked_points().size() - 1] - curve1.get_baked_points()[0]
	
	var new_curve = Curve3D.new()
	for point in curve0.get_baked_points():
		new_curve.add_point(point)
		
	for point in curve1.get_baked_points():
		new_curve.add_point(point + trans)
		
	return new_curve
