#define MAX_RAY_TRACE_STEPS 100
#define EPS 0.0001

struct Circle {
    vec2 pos;
    float r;
    vec3 color;
};

float CircleSDF(in vec2 pos, in Circle c) {
    return length(pos - c.pos) - c.r;
}

float SceneSDF(in vec2 pos, in Circle[5] obstacles) {
    float result = CircleSDF(pos, obstacles[0]);
    for (int i = 1; i < obstacles.length(); i++) {
        result = min(result, CircleSDF(pos, obstacles[i]));
    }
    return result;
}

float ShadowCasting(in vec2 pos, in Circle[5] obstacles, in Circle light) {
    vec2 resultPos = pos;
    float resultDist = 0.;
    vec2 dir = normalize(light.pos - pos);
    for (int i = 0; i < MAX_RAY_TRACE_STEPS; i++) {
        float d = SceneSDF(resultPos, obstacles);
        if (abs(d) < EPS) {
            break;
        }
        resultPos += d * dir;
        resultDist += abs(d);
    }
    return resultDist;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 c = vec3(0.);

    Circle light = Circle(vec2(0.5), 0.05, vec3(1.));
    light.pos.x += cos(iTime) / 2.5;

    vec2 lightToUV = uv - light.pos;
    c += light.r / pow(length(lightToUV), 0.8);

    Circle[5] obstacles = Circle[5] (
        Circle(iMouse.xy / iResolution.xy, 0.03, vec3(1., 0, 0)),
        Circle(vec2(0.3, 0.3), 0.04, vec3(0.4, 0.3, 0.7)),
        Circle(vec2(0.7, 0.2), 0.1, vec3(1., 0.7, 0)),
        Circle(vec2(0.6, 0.7), 0.01, vec3(1., 0, 1)),
        Circle(vec2(0.2, 0.7), 0.06, vec3(0., 0.5, 1.))
    ); 
    for (int i = 0; i < obstacles.length(); i++) {
        c += length(uv - obstacles[i].pos) < obstacles[i].r ? obstacles[i].color : vec3(0);
    }

    float surfDist = ShadowCasting(uv, obstacles, light);
    if (surfDist < length(lightToUV)) {
        c *= 0.5;
    }

    gl_FragColor = vec4(c, 1.);
}