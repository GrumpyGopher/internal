// Name: PC Mode - EGA Alt.
// Author: MustardOS
// Version: 1

void main() {
    vec3 c=texture2D(u_tex, v_uv).rgb;
    c=floor(c*3.0+0.5)/3.0;

    gl_FragColor=vec4(c, 1.0);
}
