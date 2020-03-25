mx, my = 0,0
mouse_delta = 0

function set_axes_color(axes, name, start)
    o_r, o_g, o_b, o_a = gh_polyline.get_vertex_color(pl_id, start)
    o_r, o_g, o_b, o_a = gh_polyline.get_vertex_color(pl_id, start + 1)

    r, g, b, a = gh_imgui.color_edit_rgba(name, o_r, o_b, o_g, o_a)

    gh_polyline.set_vertex_color(axes, start, r, g, b, a)
    gh_polyline.set_vertex_color(axes, start + 1, r, g, b, a)
end

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
    if (is_open == 1) then
        gh_imgui.text("GeeXLab is powerful!")
        if (gh_imgui.button("Increase radius") == 1) then
            shpere_radius = shpere_radius + 1
        end
        --flags = ImGuiInputTextFlags_None
        --text, state = gh_imgui.input_text("User name", 128, "", 0)
    end
    draw_mode = gh_imgui.checkbox("Wireframe", draw_mode)
    draw_grid = gh_imgui.checkbox("Grid", draw_grid)
    gh_imgui.separator()
    gh_imgui.text("Mouse delta: "..tostring(mouse_delta))
    gh_imgui.text("mx: "..tostring(mx).."my: "..tostring(my))

    gh_imgui.separator()
    gh_imgui.text("Plane")
    plane_x = gh_imgui.slider_1f("position_x", plane_x, -20, 20, 1)
    plane_y = gh_imgui.slider_1f("position_y", plane_y, -20, 20, 1)
    plane_z = gh_imgui.slider_1f("position_z", plane_z, -20, 20, 1)
    plane_scale = gh_imgui.slider_1f("scale", plane_scale, 1, 10, 1)
    gh_imgui.separator()
    --set_axes_color(axes, "x", 0)
    --set_axes_color(axes, "y", 2)
    --set_axes_color(axes, "z", 4)
    --ImGuiInputTextFlags_CharsDecimal        
    flags = ImGuiInputTextFlags_CharsDecimal

    text, state = gh_imgui.input_text("test", 128, "", flags)
    --if state == 1 then
        --gh_object.set_position(mesh_plane, 0, tonumber(text), 0)
    --end
    gh_imgui.text(text)
    gh_imgui.separator()
    point_on_plane = gh_imgui.slider_1f("point_on_plane", point_on_plane, 0.0, 3*math.pi, 1)

    gh_imgui.window_end()
end

--[[mx, my = gh_input.mouse_get_position()]]

function wireframe(enable)
    if enable == 1 then
        gh_renderer.wireframe();
    else
        gh_renderer.solid();
    end
end

function draw_plane(x, y, z, scale, color) 
    gh_object.set_vertices_color(mesh_id, color.r, color.g, color.b, color.a)
    gh_object.set_scale(mesh_plane, scale, scale, scale)
    gh_object.set_position(mesh_plane, x, y, z)
    gh_gpu_program.bind(simple_prog)
    gh_gpu_program.uniform4f(simple_prog, "u_color", color.r, color.g, color.b, color.a)
    gh_object.render(mesh_plane)

end
function draw_quadtree_planes(depth, px, pz, ox, oz, bx, bz, scale)
    --plane_scale = 4
    if depth < max_depth then
        if px < ox then 
            if pz < oz then
                draw_quadtree_planes(depth + 1, px, pz, ox - 0.5, oz - 0.5, bx, bz, scale / 2)
                draw_plane(plane_x - plane_scale/2, plane_y, plane_z - plane_scale/2, plane_scale, ltc)
            else
                draw_quadtree_planes(depth + 1, px, pz, ox - 0.5, oz + 0.5, bx, bz,  scale / 2)
                draw_plane(plane_x - plane_scale/2, plane_y, plane_z + plane_scale/2, plane_scale, rtc)

            end
        else
            if pz < oz then
                draw_quadtree_planes(depth + 1, px, pz, ox + 0.5, oz - 0.5, bx, bz,  scale / 2)
                draw_plane(plane_x + plane_scale/2, plane_y, plane_z - plane_scale/2, plane_scale, lbc)
            else
                draw_quadtree_planes(depth + 1, px, pz, ox + 0.5, oz + 0.5, bx, bz,  scale / 2)
                draw_plane(plane_x + plane_scale/2, plane_y, plane_z + plane_scale/2, plane_scale, rbc)
            end
        end
    end
    --draw_plane(plane_x - plane_scale/2, plane_y, plane_z - plane_scale/2, plane_scale, ltc)
    --draw_plane(plane_x - plane_scale/2, plane_y, plane_z + plane_scale/2, plane_scale, rtc)
    --draw_plane(plane_x + plane_scale/2, plane_y, plane_z - plane_scale/2, plane_scale, lbc)
    --draw_plane(plane_x + plane_scale/2, plane_y, plane_z + plane_scale/2, plane_scale, rbc)
end


function render()
    -- Textured box
    --
    --draw_box()
    draw_quadtree_planes(4, math.cos(point_on_plane), math.sin(point_on_plane), 0, 0, -1, 1, plane_scale)
    -- Grid
    --
    gh_object.set_scale(axes, 10, 10, 10)
    --gh_object.render(axes)
    if draw_grid == 1 then
        gh_gpu_program.bind(vertex_color_prog)
        gh_object.render(grid)
    end
end

function begin_frame()
    local elapsed_time = math.rad(180);--gh_utils.get_elapsed_time()

    -- Simple camera animation: we rotate around the grid at a constant height.
    --
    local rotate_speed = 0.8
    local x = 40 * math.cos(elapsed_time * rotate_speed)
    local y = 30
    local z = 40 * math.sin(elapsed_time * rotate_speed)
    gh_camera.set_position(camera, x, y, z)
    gh_camera.set_lookat(camera, 0, 0, 0, 1)

    gh_camera.bind(camera)


    gh_renderer.set_depth_test_state(1)
    gh_renderer.clear_color_depth_buffers(0.1, 0.1, 0.1, 1.0, 1.0)

    wireframe(draw_mode)

end

function end_frame() 
    gh_utils.font_render(font, 10, 20, 1.0, 1.0, 0.0, 1.0, "Textured 3D Box")
    --wireframe(0)
    imgui_frame_begin()
    test_window()
    imgui_frame_end()

end

function frame()
    begin_frame()
    check_input()
    render()
    end_frame()
end

function check_input()
    mouse_delta = gh_input.mouse_get_wheel_delta()
    mx, my = gh_input.mouse_get_position()
end

frame()

