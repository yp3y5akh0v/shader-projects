#define n 90.
#define pi radians(180.)

vec2 rot(vec2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c) * p;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 uv = (fragCoord - 0.5 * iResolution.x) / iResolution.y + vec2(0., 0.4);
    vec3 col = vec3(0.);
    float t = iTime;
    vec2 p = uv;
    float s = 0.;

    for (float i = 0.; i < mix(0., n, 0.5 + 0.5 * sin(t)); i++) {
        float itr = i / n;
        vec2 q = abs(p) - mix(1.5, -0.02, itr) * itr;
        float d = length(q);
        s += mix(0.0001, 0.002, itr) / d;
        p = rot(p, 0.05 * t);
    }

    col = vec3(s);
    fragColor = vec4(col, 1.0);
}