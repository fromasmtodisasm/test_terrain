#version 150
in vec4 gxl3d_Position;
in vec4 gxl3d_TexCoord0;
in vec4 gxl3d_Color;
out vec4 Vertex_Color;

uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GLSL Hacker
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GLSL Hacker
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GLSL Hacker
uniform vec4 u_color;

void main()
{
    //Vertex_Color = vec4(1,0,1,1);//u_color;
    Vertex_Color = u_color;
    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
}
