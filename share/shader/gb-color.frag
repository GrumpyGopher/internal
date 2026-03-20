// Name: Game Boy - Color
// Author: MustardOS
// Version: 1

void main() {
    vec2 px = 1.0 / u_resolution;

    vec3 c0 = texture2D(u_tex, v_uv).rgb;
    vec3 c1 = texture2D(u_tex, v_uv - vec2(px.x * 1.2, 0.0)).rgb;
    vec3 c = mix(c0, c1, 0.25);

    float l = dot(c, vec3(0.299, 0.587, 0.114));

    vec3 col = mix(vec3(l), c, 0.78);
    col *= vec3(0.90, 0.96, 0.92);

    float gx = 0.90 + 0.10 * sin(v_uv.x * u_resolution.x * 3.1415);
    float gy = 0.94 + 0.06 * sin(v_uv.y * u_resolution.y * 3.1415);
    float column = 0.97 + 0.03 * sin(v_uv.x * u_resolution.x * 1.5708);

    col *= gx * gy * column;

    gl_FragColor = vec4(col, 1.0);
}
