#define MAX_RAY_STEPS 100
#define EPS 0.001
#define t iTime

struct Light {
    vec3 p;
    float r;
    vec3 c;
} light;

struct RM {
    float sdf;
    float atm;
};
    
float box(vec3 p, vec3 b)
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float cylinder(vec3 p, float r) {
    return length(p.xz) - r;
}

float plane(vec3 p, float h) {
    return p.y - h;
}

float SceneSdf(vec3 p) {
    float plane = plane(p, -5.0);
    float dcBox1 = max(box(p - vec3(0., 1., 0.), vec3(1., 0.1, 1)), -cylinder(p, 0.5));
    float dcBox2 = max(box(p - vec3(0., 0., 0.), vec3(1., 0.1, 1)), -cylinder(p, 0.5));
    float d = min(dcBox1, dcBox2);
    d = min(d, plane);
    float dLight = length(light.p - p) - light.r;
    d = min(d, dLight);
    return d;
}

vec3 GetNormal(vec3 p) {
    float d = SceneSdf(p);
    vec2 e = vec2(0.001, 0.);
    vec3 n = d - vec3(
        SceneSdf(p - e.xyy),
        SceneSdf(p - e.yxy),
        SceneSdf(p - e.yyx)
    );
    
    return normalize(n);
}

float WeightedLightBlob(Light light, float decay, vec3 pos) {
    return light.r * decay / pow(length(pos - light.p), 2.);
}

RM RayMarching(vec3 ro, vec3 rd) {
    float sdf = 0.;
    float atm = 0.;
    float decay = 1.;
    vec3 pos = ro;
    for(int i = 0; i < MAX_RAY_STEPS; i++) {        
        float d = SceneSdf(pos);
        atm += WeightedLightBlob(light, decay, pos);
        if (abs(d) < EPS) {
            break;
        }
        sdf += d;
        pos += d * rd;
        decay *= 0.98;
    }
    return RM(sdf, atm);
}

vec3 RenderSceneWithLight(Light light, vec3 ro, vec3 rd) {
    RM rmMap = RayMarching(ro, rd);
    vec3 p = ro + rmMap.sdf * rd;
    vec3 n = GetNormal(p); 
    vec3 pToL = light.p - p;
    vec3 pToLN = normalize(pToL);
    float diffuse = max(dot(n, pToLN), 0.);

    vec3 col = diffuse * vec3(1.) + rmMap.atm * light.c;
    
    RM rmShadow = RayMarching(p + n, pToLN);
    if (rmShadow.sdf < length(pToL) - light.r) {
        col *= 0.3;
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{ 
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float dor = 2.5;
    vec2 cs = vec2(0.5 + 1.5 * cos(0.5 * t), 0.5 + 1.5 * sin(0.5 * t));
    vec3 ro = vec3(dor * cs.x - 2., 3. * cs.x, dor * cs.y - 2.);
    vec3 lookAt = vec3(0.);
    vec3 col = vec3(0.);
    
    vec3 oz = normalize(lookAt - ro);
    vec3 ox = normalize(cross(vec3(0., 1., 0.), oz));
    vec3 oy = normalize(cross(oz, ox));
    
    vec3 rd = uv.x * ox + uv.y * oy + oz;
    
    light = Light(vec3(0., cs.x, 0.), .01, vec3(1, 0.871, 0.231));
    col = RenderSceneWithLight(light, ro, rd);
    
    fragColor = vec4(col, 1.);
}