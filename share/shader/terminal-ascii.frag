// Name: Terminal - Ascii Edition
// Author: MustardOS
// Version: 1

float glyph(float d, vec2 p) {
    float dotc=1.0-step(0.02, dot(p-0.5, p-0.5));

    float h=step(0.45, p.y)*step(p.y, 0.55);
    float v=step(0.45, p.x)*step(p.x, 0.55);

    float diag1=1.0-step(0.08, abs(p.x-p.y));
    float diag2=1.0-step(0.08, abs(p.x-(1.0-p.y)));

    float box=step(0.25, p.x)*step(p.x, 0.75)*step(0.25, p.y)*step(p.y, 0.75);

    float g0=0.0;
    float g1=dotc;
    float g2=h;
    float g3=clamp(h+v, 0.0, 1.0);
    float g4=clamp(diag1+diag2, 0.0, 1.0);
    float g5=box;

    float a=mix(g0, g1, step(0.15, d));
    float b=mix(g2, g3, step(0.40, d));
    float c=mix(g4, g5, step(0.75, d));

    return mix(mix(a, b, step(0.30, d)), c, step(0.60, d));
}

void main() {
    float cols=64.0;
    float char_ar=2.0;

    float rows=cols/char_ar*(u_resolution.y/u_resolution.x);
    vec2 grid=vec2(cols, rows);

    vec2 cell=v_uv*grid;
    vec2 id=floor(cell);
    vec2 uv=fract(cell);

    vec2 suv=(id+0.5)/grid;
    vec3 col=texture2D(u_tex, suv).rgb;

    float l=dot(col, vec3(0.2126, 0.7152, 0.0722));
    l=pow(l, 0.85);

    float g=glyph(l, uv);
    vec3 ascii=col*g;

    gl_FragColor=vec4(ascii, 1.0);
}
