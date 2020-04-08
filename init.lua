function create_color(r,g,b,a) 
    return {r=r,g=g,b=b,a=a}
end
-- The folder of the demo. Useful for loading data with absolute path.
--
local demo_dir = gh_utils.get_demo_dir()
local lib_dir = gh_utils.get_scripting_libs_dir() 		


dofile(lib_dir .. "lua/imgui.lua")    
imgui_init()

winW, winH = gh_window.getsize(0)
font = gh_utils.font_create("Tahoma", 14)
shpere_radius = 10
-- A camera with perspective projection for 3D rendering.
--
local aspect = 1.0
if (winH > 0) then
  aspect = winW / winH
end  

world_position = {x = 1, y=4, z=3}
camera = gh_camera.create_persp(60, aspect, 1.0, 100.0)
gh_camera.set_viewport(camera, 0, 0, winW, winH)
gh_camera.set_position(camera, world_position.x, world_position.y, world_position.z)
gh_camera.set_lookat(camera, 0, 0, 0, 1)
gh_camera.setupvec(camera, 0, 1, 0, 0)


draw_mode = 0
draw_grid = 0
-- Input
--mouse_delta = 0
-- A texturing GPU program.
--
tex_prog = gh_node.getid("tex_prog")
simple_prog = gh_node.getid("simple_prog")


-- A vertex color GPU program.
--
vertex_color_prog = gh_node.getid("vertex_color_prog")

-- A texture
--
local PF_U8_RGB = 1
local PF_U8_RGBA = 3
tex0 = gh_texture.create_from_file_v5(demo_dir .. "./assets/crate.jpg", PF_U8_RGB)
height_map = gh_texture.create_from_file_v5(demo_dir .. "./assets/heightmap.png", PF_U8_RGB)
diffuse_map = gh_texture.create_from_file_v5(demo_dir .. "./assets/NE2_50M_SR_W.jpg", PF_U8_RGB)


wire_color = {r=1.0, g=1.0, b=1.0, a=1.0}
fill_color = {r=1.0, g=0.5, b=0.0, a=1.0}


boxes = {}
-- A 3D box.
--

function create_box(width, height, depth, subdivisions, radius, x, y, z)
    local result = {}
    --local mesh = gh_mesh.create_box(width, height, depth, subdivisions, subdivisions, subdivisions)
    --local mesh = gh_mesh.create_box(width, height, depth, subdivisions, subdivisions, subdivisions)
    --local mesh = gh_mesh.create_plane(20.0, 10.0, 4, 4)
    local mesh = gh_mesh.create_plane_v3(1,1, subdivisions, subdivisions, 0.0, 0.0, 0.0)
    result.mesh = mesh
    result.radius = radius
    result.height_scale = 10
    result.subdivisions = subdivisions
    local position = {
      x = x,
      y = y,
      z = z,
    }
    result.position = position
    return result
end

function create_axes()
  local LINE_RENDER_DEFAULT = 0 
  local LINE_RENDER_STRIP = 1 
  local LINE_RENDER_LOOP = 2

  --num_lines = 10000
  num_vertices = 2

  axes = gh_polyline.create_v2(num_vertices, LINE_RENDER_DEFAULT)
  -- x
  --gh_polyline.set_vertex_position(axes, 0, -1, 0, 0, 1)
  --gh_polyline.set_vertex_position(axes, 1,  1, 0, 0, 1)
  -- y
  gh_polyline.set_vertex_position(axes, 0, 0, -1, 0, 1)
  gh_polyline.set_vertex_position(axes, 1, 0, 1, 0, 1)
  gh_polyline.set_vertex_color(axes, 0, 0, 1, 0, 1)
  gh_polyline.set_vertex_color(axes, 1, 0, 1, 0, 1)
  -- z
  --gh_polyline.set_vertex_position(axes, 4, 0, 0, -1, 1)
  --gh_polyline.set_vertex_position(axes, 5, 0, 0,  1, 1)

  return axes
end

--[[
position = {x = -10, y = 0, z = 0}
table.insert(boxes, create_box(20, 20, 20, 5, 10, position))
position = {x = 10, y = 0, z = 0}
table.insert(boxes, create_box(20, 20, 20, 5, 10, position))
]]

local i = 0
--for y=-20, 20, 2.5 do
  x = 0
  y = 0
  z = 0
  for x=-5, 5, 10 do
    --for z=-20, 20, 2.5 do
      boxes[i] = create_box(20, 20, 20, 5, 1, x,y,z)
      i = i + 1
    --end
  end
--end


max_depth = 1 
-- The reference grid.
--
grid = gh_utils.grid_create()
grid_size = 40
local grid_subdivisions = 40
gh_utils.grid_set_geometry_params(grid, grid_size, grid_size, grid_subdivisions, grid_subdivisions)
gh_utils.grid_set_lines_color(grid, 0.7, 0.7, 0.7, 1.0)
gh_utils.grid_set_main_lines_color(grid, 1.0, 1.0, 0.0, 1.0)
gh_utils.grid_set_main_x_axis_color(grid, 1.0, 0.0, 0.0, 1.0)
gh_utils.grid_set_main_z_axis_color(grid, 0.0, 0.0, 1.0, 1.0)
local display_main_lines = 1
local display_lines = 1
gh_utils.grid_set_display_lines_options(grid, display_main_lines, display_lines)

plane_x, plane_y, plane_z = 0,0,0
plane_size = 1
local subdivisions =  16
mesh_plane = gh_mesh.create_plane_v3(1,1, subdivisions,subdivisions, 0.0, 0.0, 0.0)

axes = create_axes();


--[[
function = create_node(r, c)
  local result = {}
  if r == 0 then
    if c == 0 then
      result.x = 
    else

    end
  else
  end
  
end
]]


-- Misc render states.
--
gh_renderer.set_vsync(0)
gh_renderer.set_depth_test_state(1)

ltc = create_color(1,0,0,1)
rtc = create_color(0,0,1,1)
lbc = create_color(0,1,0,1)
rbc = create_color(0,1,1,1)

point_on_plane = 1.0

camera_xz_rotation=0

upx, upy, upz = 0,1,0

test_point = gh_mesh.create_plane_v3(1,1, 1, 1, 0.0, 0.0, 0.0)

recursion_count = 0

quad_tree_path = ""
test_string = ""

px_speed = 1
py_speed = 1
pause = 0
et = gh_utils.get_elapsed_time()

test_data =
{
  root_node_size = 1,
  depth = 0,
  origin = {x = 0, y = 0},
  n=0
}