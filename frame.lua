mx, my = 0,0
mouse_delta = 0
local vx, vy, vz

function create_node(x,z, color) 
    local result = {}

    result.x = x
    result.z = z
    result.scale = 32 
    result.color = color
    return result
end

function create_quad_tree(depth, x,z)
    local result = {}

    color = {r=1, g=1, b=1, a=1}
    result.node = create_node(depth, x,z, color)
    result.childs = {}
    result.childs[0] = nil
    result.childs[1] = nil
    result.childs[2] = nil
    result.childs[3] = nil
    return result

end



function traverse_tree(tree, level)
    
    if tree ~= nil then
        local cc
        --for child in tree.childs do
        --    traverse_tree(child, level)
        --end
    --
        color = {r=1, g=1, b=1, a=1}
        cc = tree.childs[0]
        if ( cc ~= nil) then
            draw_plane(cc.node.x, cc.node.y, cc.node.z, cc.node.scale, color)
            traverse_tree(cc, level + 1)
        end
        cc = tree.childs[1]
        if ( cc ~= nil) then
            draw_plane(cc.node.x, cc.node.y, cc.node.z, cc.node.scale, color)
            traverse_tree(cc, level + 1)
        end
        cc = tree.childs[2]
        if ( cc ~= nil) then
            draw_plane(cc.node.x, cc.node.y, cc.node.z, cc.node.scale, color)
            traverse_tree(cc, level + 1)
        end
        cc = tree.childs[3]
        if ( cc ~= nil) then
            draw_plane(cc.node.x, cc.node.y, cc.node.z, cc.node.scale, color)
            traverse_tree(cc, level + 1)
        end
    end


end

function draw_tree(tree)
    traverse_tree(tree, 0)
end

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
    plane_scale = gh_imgui.slider_1f("scale", plane_scale, 1, 40, 1)
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
    max_depth = gh_imgui.slider_1i("max_depth", max_depth, 0, 16)
    point_on_plane = elapsed_time-- gh_imgui.slider_1f("point_on_plane", point_on_plane, 0.0, 2*math.pi, 1)
    camera_xz_rotation = gh_imgui.slider_1f("camera_xz_rotation", camera_xz_rotation, 0.0, 2*math.pi, 1)
    gh_imgui.separator()
    gh_imgui.text("vx="..tostring(vx)..", vy="..tostring(vy)..", vz="..tostring(vz))
    gh_imgui.separator()
    gh_imgui.text("recursion_count = "..tostring(recursion_count))
    gh_imgui.text("quad_tree_path:"..quad_tree_path)
    --gh_imgui.text("test_string:"..test_string)
    flags = ImGuiInputTextFlags_Multiline
    gh_imgui.separator()
    px_speed = gh_imgui.slider_1f("px_speed", px_speed, 0.1, 1.0, 0.1)
    py_speed = gh_imgui.slider_1f("py_speed", py_speed, 0.1, 1.0, 0.1)

    text, state = gh_imgui.input_text("test_string", 4096, test_string, flags)

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

function get_quad_by_index(i)
    local result = {}
    if i == 0 then
        result.x = -0.5;
        result.y = -0.5;
        result.color = lbc
    elseif i == 1 then
        result.x = -0.5;
        result.y = 0.5;
        result.color = ltc
    elseif i == 2 then
        result.x = 0.5;
        result.y = -0.5;
        result.color = rtc
    elseif i == 3 then
        result.x = 0.5;
        result.y = 0.5;
        result.color = rbc
    end
    return result
end

function get_index_by_position(ox, oy, px, py)
    if px < ox then 
        if py < oy then
            return 0
        else
            return 1
        end
    else
        if py < oy then
            return 2
        else
            return 3
        end
    end
end

function get_offset_by_index(i)
    local ox, oy 
    if i == 0 then
        ox = -0.5;
        oy = -0.5;
    elseif i == 1 then
        ox = -0.5;
        oy = 0.5;
    elseif i == 2 then
        ox = 0.5;
        oy = -0.5;
    elseif i == 3 then
        ox = 0.5;
        oy = 0.5;
    end
    return ox, oy
end

function draw_quadtree_planes(depth, ox, oy, px, py, scale)
    local quads = {}
    local indecies = {[0] = false, [1] = false, [2] = false, [3] = false}
    local i
    if depth < max_depth then
        local sx,sy
        i = get_index_by_position(ox, oy, px, py)
        indecies[i] = true
        for i = 0, 3 do
            if indecies[i] == true then
                quad = get_quad_by_index(i)
                --draw_plane((ox + quad.x)*scale, 0, (oy + quad.y)*scale, scale, quad.color)
            else
                offset_x, offset_y = get_offset_by_index(i)
                quad_tree_path=quad_tree_path.."{"..tostring(offset_x)..", "..tostring(offset_y)
                quad_tree_path=quad_tree_path.."?"..tostring(ox)..", "..tostring(oy)
                draw_quadtree_planes(depth + 1, 2*(offset_x + ox), 2*(offset_y + oy), px, py, scale * 0.5)
                quad_tree_path=quad_tree_path.."}"
            end
        end
                --draw_plane((ox + quad.x)*scale, 0, (oy + quad.y)*scale, scale, quad.color)
                draw_plane((ox)*scale, 0, (oy)*scale, scale, lbc)
    else
    end
    return i
end


function render()
    -- Textured box
    --
    --draw_box()
    local speed = 0.8
    local et = gh_utils.get_elapsed_time()
    local px, pz = math.cos(et*px_speed), math.sin(0.5*et*py_speed)
    recursion_count = 0
    test_string=""
    quad_tree_path=""
    qx, qz = px, pz
    --qx, qz =  
    local qt = create_quad_tree(0, 0,0)
    local i = draw_quadtree_planes(0, 0,0, px, pz, plane_scale)
    quad_tree_path=quad_tree_path.."qudrant: "..tostring(i)

    draw_tree(qt)
    -- Grid
    --
    gh_object.set_scale(axes, 20, 20, 10)
    gh_gpu_program.uniform4f(simple_prog, "u_color", 0,1,0,1)
    gh_object.render(axes)
    if draw_grid == 1 then
        gh_gpu_program.bind(vertex_color_prog)
        gh_object.render(grid)
    end

    gh_object.set_position(test_point, 0.75*plane_scale * qx, 0.015, 0.75*plane_scale * qz)
    gh_gpu_program.uniform4f(simple_prog, "u_color", 1,0,0,1)
    gh_object.render(test_point)
end

function begin_frame()
    local elapsed_time = camera_xz_rotation--gh_utils.get_elapsed_time()

    -- Simple camera animation: we rotate around the grid at a constant height.
    --
    local rotate_speed = 0.8
    local x = 40 * math.cos(camera_xz_rotation)
    local y = 30
    local z = 40 * math.sin(camera_xz_rotation)
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

function check_keyboard()
    -- More key codes can be found in GeeXLab forum.
    local KC_W = 17
    local KC_S = 31
    local KC_A = 30
    local KC_D = 32
    local KC_LEFT = 75
    local KC_RIGHT = 77
    local KC_UP = 72
    local KC_DOWN = 80
    local KC_SPACE = 57

    gh_input.keyboard_update_buffer()
    local forward = gh_input.keyboard_is_key_down(KC_W)
    local backward = gh_input.keyboard_is_key_down(KC_S)
    local left = gh_input.keyboard_is_key_down(KC_A)
    local right = gh_input.keyboard_is_key_down(KC_D)

    vx,vy,vz = gh_camera.get_view(camera)
    local speed = 0.8
    if (forward == 1) then
        --gh_camera.set_position(camera, 100, 100, 100)
        --gh_camera.set_lookat(camera, 10, 10, 10)
        
        local px, py, pz = gh_camera.get_position(camera)
        nx,ny,nz = speed * gh_utils.math_normalize_vec3(gh_camera.get_view(camera))
        nx = nx + px
        ny = py
        nz = nz + pz
        gh_camera.set_position(camera,  nx,ny,nz)
    end
    if (backward == 1) then
        --gh_camera.set_position(camera, 100, 100, 100)
    end
    if (left == 1) then
        --gh_camera.set_position(camera, 100, 100, 100)
    end
    if (right == 1) then
        --gh_camera.set_position(camera, 100, 100, 100)
    end
    --gh_camera.bind(camera)

end

function check_input()
    check_keyboard()
    mouse_delta = gh_input.mouse_get_wheel_delta()
    mx, my = gh_input.mouse_get_position()

    --if gh_input.key_pressed
end

frame()

