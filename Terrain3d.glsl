#define MAX_RAY_STEPS 100
#define EPS 0.0001
#define PI radians(180.)

float rand(vec2 uv) {
    return fract(sin(dot(sin(uv), vec2(12.9898, 78.233))) * 143758.5453);
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
    	s += noise(uv, scale * k) / k;
        sk += 1. / k;
        uv *= rot(2. * PI * (i + 1.) / steps);
    } 
    return smoothstep(0., 1., s / sk);
}

struct Light {
	vec3 p;
    float r;
};

struct RayMarchInfo {
    float sdf;
    int steps;
};

float SceneSdf(vec3 p, float t) {
    float sn = 4.;
    float stn = 6.;
    float amp = 0.4;
    float d = p.y - snoise(vec2(p.x, p.z + t), sn, stn) * amp;    
    return d / sn / amp;
}

vec3 GetNormal(vec3 p, float t) {
	float d = SceneSdf(p, t);
    vec2 e = vec2(0.001, 0.);
    vec3 n = d - vec3(
        SceneSdf(p - e.xyy, t),
        SceneSdf(p - e.yxy, t),
        SceneSdf(p - e.yyx, t)
    );
    
    return normalize(n);
}

RayMarchInfo RayMarch(vec3 ro, vec3 rd, float t) {
    int raySteps = 0;
    vec3 end = ro;
    float sdf = 0.;
    for(int i = 0; i < MAX_RAY_STEPS; i++) {
        raySteps++;
    	float d = SceneSdf(end, t);
        if (abs(d) < EPS) {
        	break;
        }
        end += d * rd;
        sdf += d;
    }
    return RayMarchInfo(sdf, raySteps);
}