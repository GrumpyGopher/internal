// Name: TV RF Output
// Author: MustardOS
// Version: 1

float hash(vec2 p) {
    p=fract(p*vec2(123.34, 345.45));
    p+=dot(p, p+34.23);

    return fract(p.x*p.y);
}

void main() {
    vec2 px=vec2(1.0)/u_resolution;

    vec3 c0=texture2D(u_tex, v_uv).rgb;
    vec3 c1=texture2D(u_tex, v_uv+vec2(px.x, 0.0)).rgb;
    vec3 c2=texture2D(u_tex, v_uv-vec2(px.x, 0.0)).rgb;
    vec3 c3=texture2D(u_tex, v_uv+vec2(px.x*2.0, 0.0)).rgb;
    vec3 c4=texture2D(u_tex, v_uv-vec2(px.x*2.0, 0.0)).rgb;

    vec3 blur=(c1+c2+c3+c4)*0.25;
    float l=dot(c0, vec3(.299, .587, .114));
    vec3 col=mix(vec3(l), blur, .8);

    float ghost=texture2D(u_tex, v_uv-vec2(px.x*4.0, 0.0)).r*.25;
    float noise=hash(v_uv*u_resolution+u_time)*.08-.04;
    float scan=.85+.15*sin(v_uv.y*u_resolution.y*3.1415);

    col+=ghost;
    col+=noise;

    gl_FragColor=vec4(col*scan, 1.0);
}
