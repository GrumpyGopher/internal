// Name: Invert
// Author: MustardOS
// Version: 1

void main() {
    vec4 c = texture2D(u_tex, v_uv);
    float l = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    vec3 col = vec3(l) - c.rgb + vec3(l);

    gl_FragColor = vec4(col, c.a);
}
