shader_type spatial;

vec3 blend(float val, float a, float b, vec3 c1, vec3 c2){
	
	vec3 fc1 = float(val <= a) * c1;
	vec3 fc2 = float(val >= b) * c2;
	
	float blend = (val - a) / (b - a);
	vec3 blended = (c1 * (1.0 - blend) + c2 * (blend));
	blended *= float(val > a && val < b);
	
	return fc1 + fc2 + blended;
}

void vertex() {
	float y = VERTEX.y;
	
	VERTEX.y = y * float(y >= 0.25) + float(y < 0.25 && y>=0.005)*0.01;
	
	//COLOR.rgb = vec3(NORMAL.y);
	
	vec3 green = vec3(0.1,0.6,0.05);
	vec3 brown = vec3(0.39,0.26,0.12);
	vec3 beach = vec3(0.816,0.671,0.463);
	vec3 deep = vec3(0.0,0.027,0.439);
	vec3 shallow = vec3(0.047,0.286,0.695);
	
	vec3 land = blend(NORMAL.y,0.75,1.0,brown,green);
	land = blend(y,4.0,7.0,land,brown);
	land = blend(y,0.35,1.25,beach,land);
	
	vec3 water = blend(y,0.0,0.2,deep,shallow);
	
	
	COLOR.rgb = blend(y,0.25,0.3,water,land);
	
	//COLOR.r = calc_r(y);
	//COLOR.g = calc_g(y);
	//COLOR.b = calc_b(y);
}


void fragment(){
  ALBEDO = COLOR.xyz;
}