#define n 10.

vec2 rand(vec2 p) {
    return vec2(fract(sin(dot(sin(p), vec2(12.9898, 78.233))) * 143758.5453),
                fract(sin(dot(sin(p.yx), vec2(12.9898, 78.233))) * 143758.5453));
}

vec2 enemy = vec2(-0.2);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.x) / iResolution.y + vec2(0., 0.4);
    float t = iTime;
    vec3 col = vec3(0.);
    vec2 p = uv;
    vec2 p0 = vec2(0., 0.);
    vec2 p1 = vec2(sin(t), cos(t));
    vec2 p01 = p1 - p0;
    vec2 nP01 = normalize(p01);    
    vec2 p0p = p - p0;
    vec2 nP0P = normalize(p0p);
    vec2 p1p = p - p1;
    vec2 nP1P = normalize(p1p);    
    float projP0P = dot(p0p, nP01);
    vec2 projP0PV = projP0P * nP01;
    vec2 PtoP0P1 = p0p - projP0PV;
    float d = length(PtoP0P1);
    if (dot(nP0P, nP01) < 0.) {
        d = length(p0p);
    }
    if (dot(nP1P, -nP01) < 0.) {
        d = length(p1p);
    }
    vec3 cl = vec3(0.5, 0., 0.);
    col = .006 / d * cl.yxy;
    float r = length(p01);
    
    for (float i = 0.; i <= n; i++) {
        float circle = smoothstep(0.0035, 0., abs(length(p) - mix(0., r, i / n)));
        col += circle * cl.yxy;
    }
    
    float delayS = 2. * (0.5 + 0.5 * sin(t));
    float delayC = 40. * (0.5 + 0.5 * cos(t));
    
    enemy += 0.5 * cos(0.01 * floor(t));
    float dEnemy = .005 / length(p - enemy);
    vec3 enemyCol = dEnemy * cl.xyy;     
    
    if (delayS > 0.99) {
        float echoR = mix(r, 0., delayC);
        float circle = smoothstep(0.004, 0., abs(length(p) - echoR));
        col += circle * cl.yxy;
        enemyCol = vec3(0.);
    }
   
    col += enemyCol;
    
    vec2 targets = rand(p - pow(10., -6.) * log(t + 100.));
    float dTargets = length(targets);
    vec3 targetCol = .02 / dTargets * cl.yxy;
    col += targetCol;
    
    fragColor = vec4(col, 1.0);
}