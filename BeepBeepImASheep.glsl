#define N 40.
#define R iResolution.xy
#define t iTime
#define T (0.5 + 0.5 * sin(t))
#define D(p) ((p - 0.5 * R.xy) / R.y)
#define inf (1e38)
#define pi (radians(180.))
#define craziness 0.1

vec2 rot(vec2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c) * p;
}

float uEllipse(vec2 p, vec2 ab, float q) {
    p /= ab;
    float a = (.5 + .5 * atan(p.y, p.x) / pi);
    if (a < q) {
    	return inf;
    }
	return abs(length(p) - 1.);
}

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

vec2 QB(vec2 a, vec2 b, vec2 c, float q) {
    vec2 qab = a + q * (b - a);
    vec2 qbc = b + q * (c - b);    
    return qab + q * (qbc - qab);
}

float QBSdf(vec2 p, vec2 a, vec2 b, vec2 c) {
    float s = inf;
    for (float i = 1.; i <= N; i++) {
        vec2 qb0 = QB(a, b, c, (i - 1.) / N);
        vec2 qb1 = QB(a, b, c, i / N);
        float d = distToV(p, qb0, qb1 - qb0);
        s = min(s, d);
    }
    return s;
}

vec2 CB(vec2 a, vec2 b, vec2 c, vec2 d, float q) {
    vec2 qab = mix(a, b, q);
    vec2 qbc = mix(b, c, q);
    vec2 qcd = mix(c, d, q);
    vec2 qabc = mix(qab, qbc, q);
    vec2 qbcd = mix(qbc, qcd, q);
    return mix(qabc, qbcd, q);
}

float CBSdf(vec2 p, vec2 a, vec2 b, vec2 c, vec2 d) {
    float s = inf;
    for (float i = 1.; i <= N; i++) {
        vec2 qb0 = CB(a, b, c, d, (i - 1.) / N);
        vec2 qb1 = CB(a, b, c, d, i / N);
        float d = distToV(p, qb0, qb1 - qb0);
        s = min(s, d);
    }
    return s;
}

float Tail(vec2 p) {
	float d = inf;
	vec2 pt = rot(p - vec2(0.7, 0.03), -1.7);
    float dt = QBSdf(pt, vec2(-0.08, -0.33), vec2(-0.05, -0.21), vec2(0.05, -0.3));	
    d = min(d, dt);
    return d;
}

float Feet(vec2 p, float move) {
	float d = inf;
    float f0x = -0.3	;
    float f0y0 = -0.19;
    float f0y1 = -0.55 + move;
    float f0y01 = (f0y0 + f0y1) / 2.;
    float f0 = QBSdf(p, vec2(f0x, f0y0), vec2(f0x - 0.04 - move, f0y01), vec2(f0x, f0y1));	
    d = min(d, f0);
    
    float f1x = -0.12;
    float f1y0 = -0.18;
    float f1y1 = -0.6 + move;
    float f1y01 = (f1y0 + f1y1) / 2.;
    float f1 = QBSdf(p, vec2(f1x, f1y0), vec2(f1x - 0.04 - move, f1y01), vec2(f1x, f1y1));	
    d = min(d, f1);
    
    float f2x = 0.09;
    float f2y0 = -0.22;
    float f2y1 = -0.55 + move;
    float f2y01 = (f2y0 + f2y1) / 2.;
    float f2 = QBSdf(p, vec2(f2x, f2y0), vec2(f2x - 0.02 - move, f2y01), vec2(f2x, f2y1));	
    d = min(d, f2);

    float f3x = 0.24;
    float f3y0 = -0.24;
    float f3y1 = -0.6 + move;
    float f3y01 = (f3y0 + f3y1) / 2.;
    float f3 = QBSdf(p, vec2(f3x, f3y0), vec2(f3x - 0.02 - move, f3y01), vec2(f3x, f3y1));	
    d = min(d, f3);    
    
    return d;
}

float Body(vec2 p) {
    float d = inf;    
    p.y -= 0.07;
    vec2 p0 = rot(p - vec2(-0.43, 0.49), 0.4);
    float d0 = QBSdf(p0, vec2(-0.18, -0.3), vec2(-0.02, -0.16), vec2(0.1, -0.3));	
    d = min(d, d0);
    vec2 p1 = rot(p - vec2(-0.13, 0.58), 0.2);
    float d1 = QBSdf(p1, vec2(-0.15, -0.3), vec2(0.03, -0.13), vec2(0.15, -0.3));	
    d = min(d, d1);
    vec2 p2 = rot(p - vec2(0.31, 0.53), -0.5);
    float d2 = QBSdf(p2, vec2(-0.1, -0.3), vec2(0.06, -0.15), vec2(0.14, -0.3));	
    d = min(d, d2);
    vec2 p3 = rot(p - vec2(0.61, 0.18), -1.3);
    float d3 = QBSdf(p3, vec2(-0.1, -0.3), vec2(0.02, -0.2), vec2(0.1, -0.3));	
    d = min(d, d3);
	vec2 p4 = rot(p - vec2(0.63, -0.14), -1.7);
    float d4 = QBSdf(p4, vec2(-0.1, -0.3), vec2(0., -0.16), vec2(0.1, -0.3));	
    d = min(d, d4);
	vec2 p5 = rot(p - vec2(0.31, -.52), -2.8);
    float d5 = QBSdf(p5, vec2(-0.11, -0.3), vec2(0., -0.16), vec2(0.11, -0.3));	
    d = min(d, d5);
	vec2 p6 = rot(p - vec2(-0.04, -.56), -3.25);
    float d6 = QBSdf(p6, vec2(-0.11, -0.3), vec2(0., -0.16), vec2(0.11, -0.3));	
    d = min(d, d6);
	vec2 p7 = rot(p - vec2(-0.31, -.51), -3.4);
    float d7 = QBSdf(p7, vec2(-0.11, -0.3), vec2(0., -0.16), vec2(0.11, -0.3));	
    d = min(d, d7);    
	vec2 p8 = rot(p - vec2(-0.6, -.39), -3.7);
    float d8 = QBSdf(p8, vec2(-0.11, -0.3), vec2(-0.03, -0.19), vec2(0.05, -0.3));	
    d = min(d, d8);  
    return d;
}

float Mouse(vec2 p, int state) {
    float d = inf;
    if (state == 0) {    	
        d = distToV(p, vec2(-0.16, -0.01), vec2(0.22, 0.));
    }
    return d;
}

float Head(vec2 p) {
    float d = inf;
    p = rot(p, 0.12);
    p -= vec2(-0.46, 0.11);
    float m = Mouse(p, 0);
    d = min(d, m);
    float rEye = smoothstep(0., 0.3, length(p - vec2(0.07, 0.07)));
    d = min(d, rEye);
    float lEye = smoothstep(0., 0.3, length(p - vec2(-0.11, 0.09)));
    d = min(d, lEye);
    vec2 pLEar = rot(p - vec2(-0.07, 0.13), 1.);
    vec2 aLEar = vec2(-0.01, 0.);
    vec2 bLEar = vec2(-0.1, 0.25);
    vec2 cLEar = vec2(0.1, 0.25);
    vec2 dLEar = vec2(0.01, 0.);
    float lEar = CBSdf(pLEar, aLEar, bLEar, cLEar, dLEar);
    d = min(d, lEar);
    vec2 pREar = rot(p - vec2(0.09, 0.13), 5.);
    vec2 aREar = vec2(-0.01, 0.);
    vec2 bREar = vec2(-0.1, 0.25);
    vec2 cREar = vec2(0.1, 0.25);
    vec2 dREar = vec2(0.01, 0.);
    float rEar = CBSdf(pREar, aREar, bREar, cREar, dREar);
    d = min(d, rEar); 
    vec2 pFore = rot(p - vec2(0.01, 0.05), 0.);
    float fore = smoothstep(0., 1., uEllipse(pFore, vec2(0.1, 0.1), 0.5));
    d = min(d, fore);
    vec2 pChin0 = rot(p - vec2(-0.08, -0.01), 1.55);
    float chin0 = smoothstep(0., 1., uEllipse(pChin0, vec2(0.07, 0.135), 0.5));
    d = min(d, chin0);
    vec2 pChin1 = p - vec2(0.11, 0.05);
    vec2 aChin1 = vec2(0., 0.);
    vec2 bChin1 = vec2(0.013, -0.1);
    vec2 cChin1 = vec2(0.014, -0.13);
    vec2 dChin1 = vec2(-.2, -0.13);
    float chin1 = CBSdf(pChin1, aChin1, bChin1, cChin1, dChin1);
    d = min(d, chin1); 
            
    return d;
}

float Scene(vec2 p) {
    vec2 origp = p;
    float d = inf;
    // 13.19 rad/s which is 126 bpm per audio
    float move = mix(0., craziness, max(0., sin(13.19 * (t + 1.1))));
    p -= vec2(0., 0.1 - move);
    p = 1.3 * p;
    float body = Body(p);
    d = min(d, body);
    float head = Head(p);
    d = min(d, head);
    float tail = Tail(p);
    d = min(d, tail);
    float feet = Feet(p, move);
    d = min(d, feet);
    float field = QBSdf(origp - vec2(-0.5, -0.4), vec2(-0.7, 0.), vec2(0.5, 0.3), vec2(1.7, 0.));
    d = min(d, field);
    return 0.002 / d;
}

void mainImage(out vec4 o, in vec2 p)
{    
    o = vec4(1. - Scene(D(p)));
}