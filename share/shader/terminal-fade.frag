// Name: Terminal - Fade Edition
// Author: MustardOS
// Version: 1

float hash(vec2 p) {
    p=fract(p*vec2(123.34, 345.45));
    p+=dot(p, p+34.23);

    return fract(p.x*p.y);
}

void main() {
    float speed=.01;
    float bands=1.0;

    vec2 o=vec2(1.)/u_resolution*1.5;
    vec3 col;

    col.r=texture2D(u_tex, v_uv+o).r;
    col.g=texture2D(u_tex, v_uv).g;
    col.b=texture2D(u_tex, v_uv-o).b;

    float scan=fract(v_uv.y*bands+u_time*speed);
    float fade=exp(-scan*0.15);
    float lines=.9+.1*sin(v_uv.y*u_resolution.y*3.1415);
    float flick=hash(v_uv*u_resolution+u_time)*.04+.96;

    vec3 c=col*(.4+.6*fade)*lines*flick;

    gl_FragColor=vec4(c, 1.);
}
