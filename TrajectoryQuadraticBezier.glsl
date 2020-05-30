#define R iResolution
#define T (0.5 + 0.5 * sin(iTime))

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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * R.xy) / R.y;
    vec3 col = vec3(0.);
    vec2 p = uv;
    vec2 a = vec2(-0.6, -0.3);
    vec2 b = vec2(0., 0.4);
    vec2 c = vec2(0.6, -0.3);
    vec2 tab = a + T * (b - a);
    vec2 tbc = b + T * (c - b);
    vec2 tr = tab + T * (tbc - tab);
    float dab = distToV(p, a, tab - a);
    float dbc = distToV(p, b, tbc - b);
    float dr = distToV(p, tab, tbc - tab);
    
    col = vec3(0.003 / dab, 0.003 / dbc, 0.003 / dr);
    col += vec3(0.006 / length(p - tr));
    
    fragColor = vec4(col,1.0);
}