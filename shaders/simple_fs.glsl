#version 150

uniform sampler2D diffuse_map;
uniform vec3 color;
in vec4 Vertex_Color;

out vec4 FragColor;
void main()
{
    FragColor = Vertex_Color;
    //FragColor = vec4(1,0,1,1);
}
