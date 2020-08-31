shader_type spatial;
render_mode unshaded;

uniform sampler2D height_map_offset : hint_black;

void vertex() {
	float height = texture(height_map_offset, VERTEX.xz).r;
	VERTEX.y = height*40.0;
	COLOR.rgb = vec3(height-0.35);
}


void fragment(){
  ALBEDO = COLOR.xyz;
}
