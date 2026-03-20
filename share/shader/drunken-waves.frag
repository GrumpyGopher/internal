// Name: Drunken Waves
// Author: MustardOS
// Version: 1

float tri(float x) {
    x=fract(x*0.5+0.25);
    return abs(x-0.5)*4.0-1.0;
}

void main() {
    float t=u_time*0.0075;

    vec2 uv=v_uv;

    uv.x+=tri(v_uv.y*3.5+t*2.0)*0.010;
    uv.y+=tri(v_uv.x*3.5+t*1.6)*0.007;

    vec2 off=vec2(0.005, 0.0);

    float r=texture2D(u_tex, uv+off).r;
    float g=texture2D(u_tex, uv).g;
    float b=texture2D(u_tex, uv-off).b;

    gl_FragColor=vec4(r, g, b, 1.0);
}
