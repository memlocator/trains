import bpy

# Get the active object
obj = bpy.context.active_object

def print_packed_arr_loop(loop): #for csg debug purposes only - feel free to ignore
    print("empty\n\n")
    print("PackedVector2Array([", end="")
    for edge in loop:
        v0_index = edge.vertices[0]
        v1_index = edge.vertices[1]
        
        v0 = mesh.vertices[v0_index].co
        v1 = mesh.vertices[v1_index].co
        
        print(f"Vector2({v0.y}, {-v0.x}), ", end="")
        print(f"Vector2({v1.y}, {-v1.x}), ", end="")
    print("])", end="")
    print("fisk")
    
def print_edge_loop_extrude(loop): #what we actually use
    print("empty\n\n")
    print("PackedVector3Array([", end="")
    for edge in loop:
        v0_index = edge.vertices[0]
        v1_index = edge.vertices[1]
        
        v0 = mesh.vertices[v0_index].co
        v1 = mesh.vertices[v1_index].co
        
        print(f"Vector3({v0.y}, {-v0.x}, 0), ", end="")
    print("])", end="")
    print("fisk")
    

if obj.type == 'MESH':
    mesh = obj.data
    matrix = obj.matrix_world

    loop = [mesh.edges[0]]
    
    while len(loop) < len(mesh.edges):
        curr_edge = loop[-1] #gets the last item in the array 
        
        for edge in mesh.edges:
            #print(edge.vertices[0])
            #if edge.vertices[0] in curr_edge.vertices or edge.vertices[1] in curr_edge.vertices:
            if curr_edge.vertices[1] in edge.vertices and not curr_edge.vertices[0] in edge.vertices:
                if curr_edge.vertices[1] == edge.vertices[1]:
                    temp = edge.vertices[1]
                    edge.vertices[1] = edge.vertices[0]
                    edge.vertices[0] = temp
                if edge not in loop:
                    loop.append(edge)
    print_edge_loop_extrude(loop)
    
        