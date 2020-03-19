-- The folder of the demo. Useful for loading data with absolute path.
--
local demo_dir = gh_utils.get_demo_dir()
local lib_dir = gh_utils.get_scripting_libs_dir() 		


dofile(lib_dir .. "lua/imgui.lua")    



winW, winH = gh_window.getsize(0)



font = gh_utils.font_create("Tahoma", 14)

shpere_radius = 10




-- A camera with perspective projection for 3D rendering.
--
local aspect = 1.0
if (winH > 0) then
  aspect = winW / winH
end  
camera = gh_camera.create_persp(60, aspect, 1.0, 100.0)
gh_camera.set_viewport(camera, 0, 0, winW, winH)
gh_camera.set_position(camera, 5, 30, 50)
gh_camera.set_lookat(camera, 0, 0, 0, 1)
gh_camera.setupvec(camera, 0, 1, 0, 0)








-- A texturing GPU program.
--
tex_prog = gh_node.getid("tex_prog")


-- A vertex color GPU program.
--
vertex_color_prog = gh_node.getid("vertex_color_prog")






-- A texture
--
local PF_U8_RGB = 1
local PF_U8_RGBA = 3
tex0 = gh_texture.create_from_file_v5(demo_dir .. "./assets/crate.jpg", PF_U8_RGB)




-- A 3D box.
--
local box_width = 20
local box_height = 20
local box_depth = 20
local box_subdivisions = 20
box = gh_mesh.create_box(box_width, box_height, box_depth, box_subdivisions, box_subdivisions, box_subdivisions)



-- The reference grid.
--
grid = gh_utils.grid_create()
local grid_size = 50
local grid_subdivisions = 20
gh_utils.grid_set_geometry_params(grid, grid_size, grid_size, grid_subdivisions, grid_subdivisions)
gh_utils.grid_set_lines_color(grid, 0.7, 0.7, 0.7, 1.0)
gh_utils.grid_set_main_lines_color(grid, 1.0, 1.0, 0.0, 1.0)
gh_utils.grid_set_main_x_axis_color(grid, 1.0, 0.0, 0.0, 1.0)
gh_utils.grid_set_main_z_axis_color(grid, 0.0, 0.0, 1.0, 1.0)
local display_main_lines = 1
local display_lines = 1
gh_utils.grid_set_display_lines_options(grid, display_main_lines, display_lines)





-- Misc render states.
--
gh_renderer.set_vsync(0)
gh_renderer.set_depth_test_state(1)
