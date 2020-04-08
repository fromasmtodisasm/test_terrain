mx, my = 0,0
mouse_delta = 0
local vx, vy, vz
max_depth = 8
k = 1.1

local size_str=""
local scale_str=""
local origin_str=""

function Bounds(x1,y1, x2,y2)
    local result = {}
    result.lt = {x = x1, y = y1}
    result.rb = {x = x2, y = y2}
    return result
end

function QuadTree(x,y, color)
    local result = {}

    result.x = x
    result.y = y
    --result.bounds = bounds
    result.color = color
    result.children = {}
    return result

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
    plane_size = gh_imgui.slider_1f("size", plane_size, 1, 40, 1)
    plane_size = 20
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
    max_depth = gh_imgui.slider_1i("max_depth", max_depth, 0, 32)
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
    gh_imgui.separator()
    local px, pz = math.cos(et*px_speed), math.sin(et*py_speed)
    gh_imgui.text("px: "..px*plane_size.."pz: "..pz*plane_size)
    gh_imgui.separator()
    pause = gh_imgui.checkbox("pause", pause)
    gh_imgui.text("size: "..size_str)
    gh_imgui.text("scale: "..scale_str)
    gh_imgui.text("origin: "..origin_str)
    

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

function draw_plane(x, y, z, size, color) 
    gh_object.set_vertices_color(mesh_id, color.r, color.g, color.b, color.a)
    gh_object.set_position(mesh_plane, x, y, z)
    gh_object.set_scale(mesh_plane, size, size, size)
    gh_gpu_program.bind(simple_prog)
    gh_gpu_program.uniform4f(simple_prog, "u_color", color.r, color.g, color.b, color.a)
    gh_object.render(mesh_plane)

end

function get_quad_by_index(i)
    local result = {}
    if i == 0 then
        result.x = -1;
        result.y = -1;
        result.color = lbc
    elseif i == 1 then
        result.x = -1;
        result.y = 1;
        result.color = ltc
    elseif i == 2 then
        result.x = 1;
        result.y = -1;
        result.color = rtc
    elseif i == 3 then
        result.x = 1;
        result.y = 1;
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
        ox = -1;
        oy = -1;
    elseif i == 1 then
        ox = -1;
        oy = 1;
    elseif i == 2 then
        ox = 1;
        oy = -1;
    elseif i == 3 then
        ox = 1;
        oy = 1;
    end
    return ox, oy
end

function get_node_size(depth, root_node_size)
    return (root_node_size*math.pow(0.5, depth))
end

function get_origin(depth, pox, poy, n)
    local ox, oy = get_offset_by_index(n)
    local rx, ry
    ox = 0.5*get_node_size(depth, plane_size)*ox
    oy = 0.5*get_node_size(depth, plane_size)*oy
    rx = pox + ox
    ry = poy + oy
    return rx,ry
end

function CreateQuadTree(depth, ox, oy, px, py)
    offset_x, offset_z = get_offset_by_index(i)
    local i = get_index_by_position(ox, oy, px, py)
    local q = get_quad_by_index(i)
    pcx, pcy = get_origin(depth, ox, oy, i)
    return QuadTree(pcx, pcy, q.color)
end

function need_split(depth, x, y, ox, oy, L)
    if depth < max_depth then
        local d = math.max(
            math.min(math.abs(x-ox), math.abs(x-ox-L)), 
            math.min(math.abs(y-oy), math.abs(y-oy-L))
        )
        return d < k*L
        --return true
    end
    return false
end

function build_quadtree(qt, depth, px, py, size)
    if need_split(depth, px, py, qt.x - size*0.5, qt.y - size*0.5, size) then
        for i = 0, 3 do
            offset_x, offset_z = get_offset_by_index(i)
            local q = get_quad_by_index(i)
            pcx, pcy = get_origin(depth + 1, qt.x, qt.y, i)
            qt.children[i] = QuadTree(pcx, pcy, q.color)

            build_quadtree(
                qt.children[i], depth + 1, px, py, size*0.5
            )
            --
            --
        end
    end
end

function draw_quadtree(qt, depth, ox, oy, size)
    if qt ~= nil then
        if #qt.children == 0 then
            --quad_tree_path=quad_tree_path..tostring(depth)..","..tostring(ox)..","..tostring(oy)..","..tostring(size)..";"
            draw_plane(qt.x + ox,0,qt.y + oy, size, qt.color)
        else
            for i = 0, 3 do
                --quad_tree_path=quad_tree_path.."{"
                offset_x, offset_y = get_offset_by_index(i)
                local nox, noy = get_origin(depth + 1, ox, oy, i)
                draw_quadtree(qt.children[i], depth + 1, nox, noy, plane_size*math.pow(0.5, depth)) 
                --quad_tree_path=quad_tree_path.."}"
            end
        end
    end
end


function render()
    -- Textured box
    --
    --draw_box()
    local speed = 0.8
    if pause ~= 1 then
        et = gh_utils.get_elapsed_time()
    end
    local px, pz = math.cos(et*px_speed), math.sin(et*py_speed)
    recursion_count = 0
    test_string=""
    quad_tree_path=""
    qx, qz = px, pz
    --qx, qz =  
    local qt = QuadTree(0, 0, lbc)
    build_quadtree(qt, 0, qx, qz, plane_size)

    draw_quadtree(qt, 0, 0, 0, plane_size)
    -- Grid
    --
    gh_object.set_scale(axes, 20, 20, 10)
    gh_gpu_program.uniform4f(simple_prog, "u_color", 0,1,0,1)
    gh_object.render(axes)
    if draw_grid == 1 then
        gh_gpu_program.bind(vertex_color_prog)
        gh_object.render(grid)
    end

    gh_object.set_position(test_point, qx, 0.015, qz)
    gh_object.set_scale(test_point, 0.1, 0.1, 0.1)
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
    --gh_camera.set_position(camera, x, y, z)
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
    local speed = 0.1
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

