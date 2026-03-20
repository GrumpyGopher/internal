// Name: Chromatic Aberration
// Author: MustardOS
// Version: 1

void main() {
    vec2 o = vec2(1.5) / u_resolution;
    float a = 0.5 + 0.5 * sin(u_time * 0.5);
    vec3 c;

    c.r = texture2D(u_tex, v_uv + o * a).r;
    c.g = texture2D(u_tex, v_uv).g;
    c.b = texture2D(u_tex, v_uv - o * a).b;

    gl_FragColor = vec4(c, 1.0);
}
