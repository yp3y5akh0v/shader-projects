#define n 10.

#define rand(p) vec2(fract(sin(sin(p) * mat2(12.9898, 78.233, 78.233, 12.9898)) * 143758.5453))
#define Circle(w, p, r) smoothstep( w, 0., abs(length(p) - r ) )

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 R = iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * R) / R.y;
    float t = iTime;
    vec3 col = vec3(0.);
    vec2 p = uv;
    vec2 p1 = vec2(sin(t), cos(t));
    vec2 PtoP0P1 = p - dot(p1, p) * p1 / dot(p1, p1);
    float d = length(PtoP0P1);
    if (dot(p, p1) < 0.) {
        d = length(p);
    }
    if (dot(p - p1, -p1) < 0.) {
        d = length(p - p1);
    }
    vec2 cl = vec2(0.5, 0.);
    col = .006 / d * cl.yxy;
    float r = length(p1);
    float i = round(n * length(p) / r);
    float w = 2. * r / R.y;
    float circle = Circle(w, p, r * i / n);
    
    col += circle * cl.yxy;
    
    vec2 delay = vec2(1., 20.) * (1. + p1); 
    if (delay.x > 0.99) {
        float echoR = mix(r, 0., delay.y);
        float circle = Circle(w, p, echoR);
        col += circle * cl.yxy;
    } else {
        vec2 enemy = vec2(-0.2 + 0.5 * cos(0.01 * floor(t)));
        col += .005 / length(p - enemy) * cl.xyy;
    }
        
    float dTargets = length(rand(p - 1e-6 * log(t + 100.)));    
    col += .02 / dTargets * cl.yxy;
    
    fragColor = vec4(col, 0.0);
}