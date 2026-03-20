// Name: TV Composite (PAL) Output
// Author: MustardOS
// Version: 1

void main() {
    vec2 px=vec2(1.0)/u_resolution;

    vec3 c0=texture2D(u_tex, v_uv).rgb;
    vec3 c1=texture2D(u_tex, v_uv+vec2(px.x, 0.0)).rgb;
    vec3 c2=texture2D(u_tex, v_uv-vec2(px.x, 0.0)).rgb;
    vec3 c3=texture2D(u_tex, v_uv+vec2(px.x*2.0, 0.0)).rgb;

    float l=dot(c0, vec3(.299, .587, .114));
    vec3 chroma=(c1+c2+c3)*.333;
    vec3 col=mix(vec3(l), chroma, .7);

    float phase=mod(floor(v_uv.y*u_resolution.y), 2.0);
    col.rg+=phase*.03;
    float scan=.9+.1*sin(v_uv.y*u_resolution.y*3.1415);

    gl_FragColor=vec4(col*scan, 1.0);
}
