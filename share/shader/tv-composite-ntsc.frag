// Name: TV Composite (NTSC) Output
// Author: MustardOS
// Version: 1

void main() {
    vec2 px=vec2(1.0)/u_resolution;

    vec3 c0=texture2D(u_tex, v_uv).rgb;
    vec3 c1=texture2D(u_tex, v_uv+vec2(px.x*1.0, 0.0)).rgb;
    vec3 c2=texture2D(u_tex, v_uv-vec2(px.x*1.0, 0.0)).rgb;
    vec3 c3=texture2D(u_tex, v_uv+vec2(px.x*2.0, 0.0)).rgb;
    vec3 c4=texture2D(u_tex, v_uv-vec2(px.x*2.0, 0.0)).rgb;

    float l0=dot(c0, vec3(.299, .587, .114));
    vec3 chroma=(c1+c2+c3+c4)*0.25;
    vec3 col=mix(vec3(l0), chroma, .75);

    float phase=sin(v_uv.y*u_resolution.y*1.5708+u_time*.5);
    col.rg+=phase*.04;
    col.b-=phase*.03;

    float ghost=texture2D(u_tex, v_uv-vec2(px.x*4.0, 0.0)).r*.15;
    col+=ghost;
    float scan=.9+.1*sin(v_uv.y*u_resolution.y*3.1415);

    gl_FragColor=vec4(col*scan, 1.0);
}
