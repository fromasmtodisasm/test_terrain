#version 150

uniform vec3 WIRE_COL;
uniform vec3 FILL_COL;
uniform sampler2D diffuse_map;
in vec3 dist;
in vec2 v_uv;
out vec4 FragColor;
void main()
{
  // Undo perspective correction.      
  //vec3 dist_vec = dist * gl_FragCoord.w;
  
  // Wireframe rendering is better like this:
  vec3 dist_vec = dist;
  
  // Compute the shortest distance to the edge
  float d = min(dist_vec[0], min(dist_vec[1], dist_vec[2]));

  // Compute line intensity and then fragment color
	float I = exp2(-2.0*d*d);

	FragColor.rgb = I*WIRE_COL + (1.0 - I)*FILL_COL; 
  FragColor.rgb = texture2D(diffuse_map, v_uv).rgb;
  FragColor.a = 1.0;
}
