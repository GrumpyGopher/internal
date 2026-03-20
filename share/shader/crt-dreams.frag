// Name: CRT Dreams
// Author: MustardOS
// Version: 1

void main() {
    vec2 uv=v_uv*2.0-1.0;
    float r=dot(uv, uv);

    uv*=1.0+r*0.05;
    uv=uv*0.5+0.5;

    float inside=step(0.0, uv.x)*step(0.0, uv.y)*step(uv.x, 1.0)*step(uv.y, 1.0);
    vec3 col=texture2D(u_tex, uv).rgb*inside;

    float h=.85+.15*sin(v_uv.y*u_resolution.y*3.1415);
    float v=.92+.08*sin(v_uv.x*u_resolution.x*3.1415);

    float vig=1.0-r*0.35;
    col*=h*v*vig;

    gl_FragColor=vec4(col, 1.0);
}
