#define N 40.
#define R iResolution.xy
#define M iMouse.xy
#define t iTime
#define T (0.5 + 0.5 * sin(t))
#define D(p) (((p) - 0.5 * R) / R.y)
#define inf 1e32

float distToV(vec2 p, vec2 o, vec2 v) {
    vec2 op = p - o;
    vec2 ep = op - v;
    float d = length(ep - dot(ep, v) / dot(v, v) * v);
    if (dot(op, v) < 0.) {
        d = length(op);
    }    
    if (dot(ep, -v) < 0.) {
        d = length(ep);
    }
    return d;
}

vec2 QuadraticBezier(vec2 a, vec2 b, vec2 c, float q) {
    vec2 qab = a + q * (b - a);
    vec2 qbc = b + q * (c - b);    
    return qab + q * (qbc - qab);
}

void mainImage(out vec4 o, in vec2 p)
{
    p = D(p);
    vec2 m = D(M);    
    vec2 a = vec2(-0.6, -0.3);
    vec2 b = vec2(m.x, m.y);
    vec2 c = vec2(0.6, -0.3);
    float s = inf;
    
    for (float i = 1.; i <= N; i++) {
        vec2 qb0 = QuadraticBezier(a, b, c, (i - 1.) / N);
        vec2 qb1 = QuadraticBezier(a, b, c, i / N);
        float d = distToV(p, qb0, qb1 - qb0);
        s = min(s, d);
    }
    
    vec2 tab = a + T * (b - a);
    vec2 tbc = b + T * (c - b);
    vec2 tr = tab + T * (tbc - tab);
    float dab = distToV(p, a, tab - a);
    float dbc = distToV(p, b, tbc - b);
    float dr = distToV(p, tab, tbc - tab);
    
    o = vec4(0.002 / s);
    o += vec4(0.003 / dab, 0.003 / dbc, 0.003 / dr, 0.);
    o += vec4(0.004 / length(p - tr));
}