shader_type spatial;
//render_mode unshaded;


uniform uint seed = uint(1);
uniform vec3 offset = vec3(0,0,0);
uniform float speed = 1;

uniform float scale = 1;
uniform int octaves = 4;
uniform float persistence = 2.0;
uniform float lacunarity = 0.5;

uniform float raise_exp = 2.0;


vec3 mod289_3(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289_4(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289_4(((x * 34.0) + 1.0) * x);
}

vec4 taylorInvSqrt(vec4 r) {
    return 2.79284291400159 - 0.85373472095314 * r;
}


float openSimplex3d(vec3 v) { 
    vec2 C = vec2(1.0/6.0, 1.0/3.0) ;
    vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
    
    // First corner
    vec3 i  = floor(v + dot(v, vec3(C.y)) );
    vec3 x0 = v - i + dot(i, vec3(C.x)) ;
    
    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );
    
    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + vec3(C.x);
    vec3 x2 = x0 - i2 + vec3(C.y); // 2.0*C.x = 1/3 = C.y
    vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
    
    // Permutations
    i = mod289_3(i); 
    vec4 p = permute( permute( permute( 
    		 i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
    	   + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
    	   + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
    
    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;
    
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
    
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
    
    vec4 x = x_ *ns.x + vec4(ns.y);
    vec4 y = y_ *ns.x + vec4(ns.y);
    vec4 h = 1.0 - abs(x) - abs(y);
    
    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );
    
    //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    
    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
    
    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);
    
    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    
    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), vec4(0.0));
    m = m * m;
    return 22.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
}

float fractalNoise3d(vec3 coord){
	float normal = 0.0;
	float amp = 1.0;
	float freq = 1.0;
	vec3 adjusted_coord;
	
	float value = 0.0;
	for(int i = 0; i < octaves; i++){
		
		adjusted_coord = coord * freq;
		value += openSimplex3d(adjusted_coord) * amp;
		normal += amp;

		amp *= persistence;
		freq *= lacunarity;
	}
	return max(0.0,value / normal * 0.5 + 0.5);
}

float simple_hash(uint val){
	val+=(val<<uint(5));
	val=val^(val>>uint(3));
	
	return float(val);
}

float distance_percent(float x, float y){
	return 2.0-8.0*(pow(0.5-x,2.0) + pow(0.5-y,2.0)); 
}

float islandHeight(vec3 coord){
	float xx = coord.x;
	float yy = coord.y;
	
	coord.xy += offset.xy;
	coord.xy *= scale;
	coord.z *= speed;
	coord.z += simple_hash(seed) + offset.z;
	
	float base_noise = fractalNoise3d(coord);
	base_noise *= distance_percent(xx,yy);
	base_noise = pow(max(base_noise,0.1)-0.1,raise_exp)*raise_exp;
	
	base_noise *= 2.0;
	
	return base_noise;
}

float shallows(float h){
	return float(h < 0.05);
}
float beach(float h){
	return float(h >= 0.05 && h < 0.15);
}
float grass1(float h){
	return float(h >= 0.15 && h < 0.6);
}
float grass2(float h){
	return float(h >= 0.6 && h < 1.6);
}
float grass3(float h){
	return float(h >= 1.6 && h < 3.4);
}
float rock1(float h){
	return float(h >= 3.4);
}


float calc_r(float h){
	return shallows(h)*0.047 + beach(h)*0.816 + grass1(h)*0.345 + grass2(h)*0.153 + grass3(h)*0.298 + rock1(h)*0.584;
}
float calc_g(float h){
	return shallows(h)*0.286 + beach(h)*0.671 + grass1(h)*0.494 + grass2(h)*0.298 + grass3(h)*0.212 + rock1(h)*0.586;
}
float calc_b(float h){
	return shallows(h)*0.695 + beach(h)*0.463 + grass1(h)*0.192 + grass2(h)*0.0 + grass3(h)*0.0 + rock1(h)*0.533;
}

void vertex() {
    float height = islandHeight(vec3(UV, TIME));

	COLOR.rgb = vec3(calc_r(height),calc_g(height),calc_b(height));
	
	VERTEX.y = height;
	
	vec2 e = vec2(0.01, 0.0);
	vec3 normal = normalize(vec3(islandHeight(vec3(VERTEX.xz - e,TIME)) - islandHeight(vec3(VERTEX.xz + e,TIME)), 2.0 * e.x, islandHeight(vec3(VERTEX.xz - e.yx,TIME)) - islandHeight(vec3(VERTEX.xz + e.yx,TIME))));
	NORMAL = normal;
	
}
void fragment(){
  ALBEDO = COLOR.xyz;
}