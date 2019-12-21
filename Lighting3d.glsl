#define MAX_RAY_STEPS 100
#define EPS 0.0001
#define PI radians(180.)

struct Light {
	vec3 p;
    float r;
};

struct RayMarchInfo {
    float sdf;
    int steps;
};
    
float box(vec3 p, vec3 b)
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float cylinder(vec3 p, float r) {
	return length(p.xz) - r;
}

mat3 rot(float a, float b, float g) {
	float ca = cos(a);
    float sa = sin(a);
	float cb = cos(b);
    float sb = sin(b);
    float cg = cos(g);
    float sg = sin(g);
    mat3 ma = mat3(ca, sa, 0., -sa, ca, 0., 0., 0., 1.);
    mat3 mb = mat3(cb, 0., sb, 0., 1., 0., -sb, 0., cb);
    mat3 mg = mat3(1., 0., 0., 0., cg, sg, 0, -sg, cg);
    return ma * mb * mg;
}

vec3 rotX(vec3 p, float a) {
 return p * rot(a, 0., 0.);
}

vec3 rotY(vec3 p, float b) {
 return p * rot(0., b, 0.);
}

vec3 rotZ(vec3 p, float g) {
 return p * rot(0., 0., g);
}

float SceneSdf(vec3 p, float t) {
    float plane = p.y + 0.3;
    vec3 c = vec3(0.5);  
 	p -= c;
    p = rotZ(p, PI + 0.5 * cos(t));
    p = rotX(p, PI + 0.5 * sin(t));
    p = rotY(p, PI + 0.5 * cos(t));
    float dBox = box(p, vec3(0.7, 0.07, 0.45));
    float dCylinder = cylinder(p, 0.15);
    float d = max(dBox, -dCylinder); 
    d = min(d, plane);
    return d;
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{ 
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.));
    vec3 ro = vec3(0.5, 0.5, -2.);
    vec3 col = vec3(0.);
    float t = iTime;
    
    Light light = Light(vec3(0.5 + sin(t), 1.5, 0.1), 0.07);
    RayMarchInfo rmi = RayMarch(ro, rd, t);

    vec3 p = ro + rmi.sdf * rd;
    vec3 n = GetNormal(p, t); 
    vec3 pToL = light.p - p;
    vec3 pToLN = normalize(pToL);
    
    RayMarchInfo lrmi = RayMarch(p + 0.3 * n, pToLN, t);
    
    col = vec3(1. / pow(length(pToL), 0.8));
    
    float diffuse = clamp(dot(n, pToLN), 0., 1.);
    
    if (lrmi.sdf < length(pToL) - light.r) {
    	col *= 0.3;
    }
    
    col *= diffuse;
    
    float fogCoef = 1. - exp(-rmi.sdf * 0.2);
    float rxL = max(dot(rd, normalize(light.p - ro)), 0.);
    vec3 fogCol = mix(vec3(0.53, 0.81, 0.92), vec3(0.98, 0.83, 0.64), pow(rxL, 50.));
    
    col = mix(col, fogCol, fogCoef);
    col += pow(rxL, 200. * length(light.p - ro));
    
    fragColor = vec4(col, 1.0);
}