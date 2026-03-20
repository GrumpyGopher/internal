// Name: PC Mode - VGA Alt.
// Author: MustardOS
// Version: 1

void main() {
    vec3 c=texture2D(u_tex, v_uv).rgb;
    vec3 q=floor(c*5.0+0.5)/5.0;

    gl_FragColor=vec4(q, 1.0);
}
