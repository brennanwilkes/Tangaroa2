shader_type spatial;

uniform vec3 grey = vec3(0.365,0.333,0.294);
uniform vec3 grass = vec3(0.098,0.191,0.075);
uniform vec3 brown = vec3(0.39,0.26,0.12);
uniform vec3 beach = vec3(0.816,0.671,0.463);
uniform vec3 deep = vec3(0.0,0.027,0.439);
uniform vec3 shallow = vec3(0.047,0.286,0.695);


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
    
    VERTEX.y = y * float(y >= 0.3) + float(y < 0.3)*0.01;
    
    
    
    vec3 land = blend(NORMAL.y,0.75,1.0,brown,grass);
    land = blend(y,4.0,8.0,land,brown);
    land = blend(NORMAL.y,0.35,0.6,grey,land);
    land = blend(y,8.0,32.0,land,grey);
    
    vec3 shore = blend(NORMAL.y,0.8,0.85,brown,beach);    
    land = blend(y,0.45,0.85,shore,land);
    
    vec3 water = blend(y,0.0,0.2,deep,shallow);
    
    
    COLOR.rgb = blend(y,0.25,0.3,water,land);
    
}


void fragment(){
  ALBEDO = COLOR.rgb;
}
