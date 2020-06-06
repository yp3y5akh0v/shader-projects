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

vec2 CubicBezier(vec2 a, vec2 b, vec2 c, vec2 d, float q) {
    vec2 qab = mix(a, b, q);
    vec2 qbc = mix(b, c, q);
    vec2 qcd = mix(c, d, q);
    vec2 qabc = mix(qab, qbc, q);
    vec2 qbcd = mix(qbc, qcd, q);
    return mix(qabc, qbcd, q);
}

void mainImage(out vec4 o, in vec2 p)
{
    p = D(p);
    vec2 m = D(M);    
    vec2 a = vec2(0., -0.3);
    vec2 b = vec2(-2. + T, 0.5);
    vec2 c = vec2(2. - T, 0.5);
    vec2 d = vec2(0., -0.3);
    float s = inf;
    
    for (float i = 1.; i <= N; i++) {
        vec2 qb0 = CubicBezier(a, b, c, d, (i - 1.) / N);
        vec2 qb1 = CubicBezier(a, b, c, d, i / N);
        float d = distToV(p, qb0, qb1 - qb0);
        s = min(s, d);
    }
    
    vec2 tab = mix(a, b, T);
    vec2 tbc = mix(b, c, T);
    vec2 tcd = mix(c, d, T);
    vec2 tabc = mix(tab, tbc, T);
    vec2 tbcd = mix(tbc, tcd, T);
    vec2 tr = mix(tabc, tbcd, T);
    
    o = vec4(0.002 / s + 0.004 / length(p - tr));
}