@tool
extends MeshInstance3D

func move_forward(crossSection, vector):
	for vertex in crossSection:
		vertex += vector
	return crossSection
# Called when the node enters the scene tree for the first time.

var cross_section_points = PackedVector3Array([Vector3(-0.7923468947410583, -0.0031647791620343924, 0), Vector3(-0.7923470139503479, -0.07024983316659927, 0), Vector3(-0.39617350697517395, -0.07024992257356644, 0), Vector3(-3.756487444240078e-14, -0.0702500119805336, 0), Vector3(0.39617350697517395, -0.07024992257356644, 0), Vector3(0.7923470139503479, -0.07024983316659927, 0), Vector3(0.7923470139503479, -0.003164831316098571, 0), Vector3(0.7923470139503479, 0.06392016261816025, 0), Vector3(0.7343460321426392, 0.07994666695594788, 0), Vector3(0.6763449907302856, 0.09597316384315491, 0), Vector3(0.3989979922771454, 0.11886816471815109, 0), Vector3(0.12165100127458572, 0.14176316559314728, 0), Vector3(0.12058250606060028, 0.5042691826820374, 0), Vector3(0.11951400339603424, 0.8667751550674438, 0), Vector3(0.14515650272369385, 0.8933336734771729, 0), Vector3(0.17079900205135345, 0.9198921918869019, 0), Vector3(0.29534849524497986, 0.958355724811554, 0), Vector3(0.41989800333976746, 0.9968191981315613, 0), Vector3(0.4391300082206726, 1.0096397399902344, 0), Vector3(0.45836201310157776, 1.0224602222442627, 0), Vector3(0.4583619236946106, 1.1224602460861206, 0), Vector3(0.4583618640899658, 1.2224602699279785, 0), Vector3(0.4363824129104614, 1.2362003326416016, 0), Vector3(0.4144029915332794, 1.249940276145935, 0), Vector3(0.3731920123100281, 1.257265329360962, 0), Vector3(0.33198100328445435, 1.2645902633666992, 0), Vector3(0.16599050164222717, 1.2645902633666992, 0), Vector3(-3.756487444240078e-14, 1.2645902633666992, 0), Vector3(-0.1659904420375824, 1.264589548110962, 0), Vector3(-0.3319808840751648, 1.2645889520645142, 0), Vector3(-0.37319207191467285, 1.2572624683380127, 0), Vector3(-0.4144032597541809, 1.2499361038208008, 0), Vector3(-0.43638256192207336, 1.2361990213394165, 0), Vector3(-0.4583618640899658, 1.2224619388580322, 0), Vector3(-0.4583618640899658, 1.1224619150161743, 0), Vector3(-0.4583618640899658, 1.0224618911743164, 0), Vector3(-0.4391299784183502, 1.0096406936645508, 0), Vector3(-0.4198980927467346, 0.9968193173408508, 0), Vector3(-0.29534873366355896, 0.9583555459976196, 0), Vector3(-0.1707993894815445, 0.9198917746543884, 0), Vector3(-0.1451568752527237, 0.8933334946632385, 0), Vector3(-0.11951436847448349, 0.8667751550674438, 0), Vector3(-0.12058280408382416, 0.5042694211006165, 0), Vector3(-0.12165124714374542, 0.1417636126279831, 0), Vector3(-0.39899808168411255, 0.11886851489543915, 0), Vector3(-0.6763449311256409, 0.0959734097123146, 0), Vector3(-0.7343458533287048, 0.0799468383193016, 0), Vector3(-0.7923467755317688, 0.0639202669262886, 0)])
var cross_section_points_len = len(cross_section_points)
func _ready():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var moved_cross_section = Array(cross_section_points)
	for vertex_idx in moved_cross_section.size():
		moved_cross_section[vertex_idx] = moved_cross_section[vertex_idx] + Vector3(0,0,1)
	var cross_sections = PackedVector3Array(cross_section_points)
	cross_sections.append_array(moved_cross_section)
	
	var cross_sections_count = 2
	
	var verts = cross_sections#PackedVector3Array()
	var indices = PackedInt32Array()
	
	
	
	for i in cross_sections_count: #i
		if i == 0:
			continue
		for j in cross_section_points_len:
			#var prev = i * cross_section_points_len + (j + cross_section_points_len - 1) % cross_section_points_len
			#var lastSectionJ = (i-1) * cross_section_points_len + j
			#var lastSectionPrev = (i - 1) * cross_section_points_len + (j + cross_section_points_len - 1) % cross_section_points_len
#
			#var prev_vtx = cross_sections[prev]
			#var j_vtx = cross_sections[j]
			#var last_sect_prev_vtx = cross_sections[lastSectionPrev]
			#var last_sect_j = cross_sections[lastSectionJ]
			
			var vertA = cross_section_points_len * i + j
			var vertB = cross_section_points_len * i + (j - 1 + cross_section_points_len) % cross_section_points_len #// prev

			var vertC = cross_section_points_len * (i - 1) + j
			var vertD = cross_section_points_len * (i - 1) + (j - 1 + cross_section_points_len)%cross_section_points_len
			
			#normal_v0 = verts[vertC] - 
			
			indices.append(vertC)
			indices.append(vertB)
			indices.append(vertA)

			indices.append(vertB)
			indices.append(vertC)
			indices.append(vertD)

		

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices
	print(len(verts),  ", ", len(indices))
	print(indices)
	#print(indices, len(indices)%3)
	#print(verts, len(verts))
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
