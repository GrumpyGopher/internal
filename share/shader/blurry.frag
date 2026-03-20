// Name: Blurry
// Author: MustardOS
// Version: 1

void main() {
    vec2 px=1.0/u_resolution;
    vec2 o=vec2(px.x*6.0, 0.0);

    vec3 a=texture2D(u_tex, v_uv-o*2.0).rgb;
    vec3 b=texture2D(u_tex, v_uv-o).rgb;
    vec3 c=texture2D(u_tex, v_uv).rgb;
    vec3 d=texture2D(u_tex, v_uv+o).rgb;
    vec3 e=texture2D(u_tex, v_uv+o*2.0).rgb;

    vec3 col=a*0.10+b*0.20+c*0.40+d*0.20+e*0.10;

    gl_FragColor=vec4(col, 1.0);
}