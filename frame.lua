function test_window() 
    -- Window options
    local window_default = 0
    local window_no_resize = 2
    local window_no_move = 4
    local window_no_collapse = 32
    local window_show_border = 128
    local window_no_save_settings = 256

    -- Position or size options
    local pos_size_flag_always = 1 -- Always set the pos and/or size
    local pos_size_flag_once = 2 -- Set the pos and/or size once per runtime session (only the first call with succeed)
    local pos_size_flag_first_use_ever = 4 -- Set the pos and/or size if the window has no saved data (if doesn't exist in the .ini file)
    local pos_size_flag_appearing = 8 -- Set the pos and/or size if the window is appearing after being hidden/inactive (or the first time)

    -- window_flags = window_no_move | window_no_save_settings
    window_flags = 0
    pos_flags = pos_size_flag_first_use_ever
    size_flags = pos_size_flag_first_use_ever

    is_open = gh_imgui.window_begin("GeeXLab ImGui demo", 300, 200, 20, 20, window_flags, pos_flags, size_flags)
    --[[
    if (is_open == 1) then
        gh_imgui.text("GeeXLab is powerful!")
    end
    ]]

    gh_imgui.window_end()
end

local elapsed_time = gh_utils.get_elapsed_time()


--test_window()
imgui_frame_begin()
gh_imgui.show_demo_window()
imgui_frame_end()

-- Simple camera animation: we rotate around the grid at a constant height.
--
local rotate_speed = 0.8
local x = 40 * math.cos(elapsed_time * rotate_speed)
local y = 30
local z = 40* math.sin(elapsed_time * rotate_speed)
gh_camera.set_position(camera, x, y, z)
gh_camera.set_lookat(camera, 0, 0, 0, 1)

gh_camera.bind(camera)






gh_renderer.set_depth_test_state(1)
gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)

gh_renderer.wireframe();

-- Textured box
--
local texture_unit = 0
gh_texture.bind(tex0, texture_unit)

gh_gpu_program.bind(tex_prog)
gh_gpu_program.uniform1f(tex_prog, "radii", shpere_radius)
gh_object.render(box)



-- Grid
--
--gh_gpu_program.bind(vertex_color_prog)
--gh_object.render(grid)





gh_utils.font_render(font, 10, 20, 1.0, 1.0, 0.0, 1.0, "Textured 3D Box")

