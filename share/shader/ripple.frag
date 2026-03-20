// Name: Ripple
// Author: MustardOS
// Version: 1

void main() {
    vec2 uv=v_uv-0.5;

    float t=u_time*0.025;
    float r=length(uv);

    float wave=sin(r*18.0-t*1.8)*0.008;
    vec2 dir=uv/(r+0.0001);

    vec2 p=v_uv+dir*wave;
    vec3 col=texture2D(u_tex, p).rgb;

    gl_FragColor=vec4(col, 1.0);
}
