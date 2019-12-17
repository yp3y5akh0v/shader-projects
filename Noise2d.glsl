#define PI radians(180.)

float rand(vec2 uv) {
	return fract(8712913.13 * (sin(dot(uv, vec2(932124.23, 2413234.11))) + 1.) / 2.);
}

mat2 rot(float a) {
	float ca = cos(a);
    float sa = sin(a);
    return mat2(ca, -sa, sa, ca);
}

float noise(vec2 uv, float scale) {
    vec2 uvs = uv * scale;
	vec2 id = floor(uvs);
    vec2 q = smoothstep(0., 1., fract(uvs));
    vec2 e = vec2(1, 0);
     
    float rsx = mix(rand(id), rand(id + e.xy), q.x);
    float rnx = mix(rand(id + e.yx), rand(id + e.xx), q.x);
    
    return mix(rsx, rnx, q.y);
}

float snoise(vec2 uv, float scale, float steps) {
	float s = 0., sk = 0.; 
    for (float i = 0.; i < steps; i++) {
        float k = pow(2., i);
    	s += noise(uv, scale * (i + 1.)) / k;
        sk += 1. / k;
        uv *= rot(2. * PI * (i + 1.) / steps);
    } 
    return s / sk;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 uv = fragCoord / iResolution.xy;
    float r = snoise(uv + iTime * 0.1, 6., 32.);
	vec3 col = vec3(r);
    
    fragColor = vec4(col,1.0);
}