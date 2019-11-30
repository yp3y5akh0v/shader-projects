#define MAX_RAY_TRACE_STEPS 20
#define EPS 0.0001
#define N 5

struct Circle {
    vec2 pos;
    float r;
    vec3 color;
};

Circle obstacles[N];
Circle light;
    
float CircleSDF(vec2 pos, Circle c) {
    return length(pos - c.pos) - c.r;
}

float SceneSDF(vec2 pos) {
    float result = CircleSDF(pos, obstacles[0]);
    for (int i = 1; i < N; i++) {
        result = min(result, CircleSDF(pos, obstacles[i]));
    }
    return result;
}

float ShadowCasting(vec2 pos) {
    vec2 resultPos = pos;
    float resultDist = 0.;
    vec2 dir = normalize(light.pos - pos);
    for (int i = 0; i < MAX_RAY_TRACE_STEPS; i++) {
        float d = SceneSDF(resultPos);
        if (abs(d) < EPS) {
            break;
        }
        resultPos += d * dir;
        resultDist += abs(d);
    }
    return resultDist;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.y;
    vec3 c = vec3(0.);

    light = Circle(vec2(0.5), 0.05, vec3(1.));
    light.pos.x += cos(iTime) / 2.5;

    vec2 lightToUV = uv - light.pos;
    c += light.r / pow(length(lightToUV), 0.8);

    obstacles[0] = Circle(iMouse.xy / iResolution.y, 0.03, vec3(1., 0, 0));
    obstacles[1] = Circle(vec2(0.3, 0.3), 0.04, vec3(0.4, 0.3, 0.7));
    obstacles[2] = Circle(vec2(0.7, 0.2), 0.1, vec3(1., 0.7, 0));
    obstacles[3] = Circle(vec2(0.6, 0.7), 0.02, vec3(1., 0, 1));
    obstacles[4] = Circle(vec2(0.2, 0.7), 0.06, vec3(0., 0.5, 1.));
    
    for (int i = 0; i < N; i++) {
        c += length(uv - obstacles[i].pos) < obstacles[i].r ? 
            obstacles[i].color :
            vec3(0);
    }

    float surfDist = ShadowCasting(uv);
    if (surfDist < length(lightToUV) - EPS) {
        c *= 0.5;
    }

    fragColor = vec4(c, 1.);    
}