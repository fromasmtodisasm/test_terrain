#version 150
in vec4 gxl3d_Position;
in vec4 gxl3d_TexCoord0;

out vec4 v_uv;
out vec4 v_normal;
out vec4 v_lightdir;
out vec4 v_eyedir;
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GLSL Hacker
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GLSL Hacker
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GLSL Hacker
uniform vec4 light_position = vec4(10,10, 10, 1);
uniform float radii;
uniform float height_scale = 10;

uniform sampler2D tex0;
//uniform vec4 uv_tiling;
void main()
{
  float height = 0;//texture2D(tex0, gxl3d_TexCoord0.xy).r;
  vec4 position = normalize(gxl3d_ModelViewProjectionMatrix * gxl3d_Position);
  vec4 mv_position = gxl3d_ModelViewMatrix * vec4((radii + height*height_scale) * normalize(gxl3d_Position));
  gl_Position = /*gxl3d_ModelViewProjectionMatrix **/ (vec4((radii + height*height_scale) * normalize(gxl3d_Position.xyz), gxl3d_Position.w));
  v_normal = normalize(vec4(mv_position.xyz, 0.0));
  v_uv = gxl3d_TexCoord0;// * uv_tiling;
  vec4 view_vertex = gxl3d_ModelViewMatrix * gxl3d_Position;
  vec4 lp = gxl3d_ViewMatrix * light_position;
  v_lightdir = lp - view_vertex;
  v_eyedir = -view_vertex;
}