shader_type spatial;


float deep(float h){
	return float(h < 0.005);
}
float shallows(float h){
	return float(h < 0.25 && h > 0.005);
}
float beach(float h){
	return float(h >= 0.25 && h < 1.0);
}
float grass1(float h){
	return float(h >= 1.0 && h < 2.6);
}
float grass2(float h){
	return float(h >= 2.6 && h < 6.0);
}
float grass3(float h){
	return float(h >= 6.0 && h < 8.0);
}
float rock1(float h){
	return float(h >= 8.0);
}


float calc_r(float h){
	return deep(h)*0.0 + shallows(h)*0.047 + beach(h)*0.816 + grass1(h)*0.345 + grass2(h)*0.153 + grass3(h)*0.298 + rock1(h)*0.584;
}
float calc_g(float h){
	return deep(h)*0.027 + shallows(h)*0.286 + beach(h)*0.671 + grass1(h)*0.494 + grass2(h)*0.298 + grass3(h)*0.212 + rock1(h)*0.586;
}
float calc_b(float h){
	return deep(h)*0.439 + shallows(h)*0.695 + beach(h)*0.463 + grass1(h)*0.192 + grass2(h)*0.0 + grass3(h)*0.0 + rock1(h)*0.533;
}

void vertex() {
	float y = VERTEX.y;
	
	VERTEX.y = y * float(y >= 0.25) + float(y < 0.25 && y>=0.005)*0.01;
	
	COLOR.r = calc_r(y);
	COLOR.g = calc_g(y);
	COLOR.b = calc_b(y);
}


void fragment(){
  ALBEDO = COLOR.xyz;
}