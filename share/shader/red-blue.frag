// Name: Red Blue Stereo
// Author: MustardOS
// Version: 1

void main() {
    vec2 px=1.0/u_resolution;
    float base=px.x*5.0;
    float t=u_time*0.18;
    float depth=base+sin(t)*px.x*0.6;

    vec3 left=texture2D(u_tex, v_uv-vec2(depth, 0.0)).rgb;
    vec3 right=texture2D(u_tex, v_uv+vec2(depth, 0.0)).rgb;
    vec3 center=texture2D(u_tex, v_uv).rgb;

    vec3 col=vec3(left.r, right.g, right.b);
    col=mix(center, col, 0.85);

    gl_FragColor=vec4(col, 1.0);
}
