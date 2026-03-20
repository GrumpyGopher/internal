// Name: Game Boy - Pocket Alt.
// Author: MustardOS
// Version: 1

void main() {
    vec2 px = 1.0 / u_resolution;

    vec3 c0 = texture2D(u_tex, v_uv).rgb;
    vec3 c1 = texture2D(u_tex, v_uv - vec2(px.x * 1.2, 0.0)).rgb;
    vec3 c = mix(c0, c1, 0.30);

    float l = dot(c, vec3(0.299, 0.587, 0.114));

    vec3 p0 = vec3(0.05, 0.10, 0.12);
    vec3 p1 = vec3(0.28, 0.42, 0.46);
    vec3 p2 = vec3(0.58, 0.72, 0.75);
    vec3 p3 = vec3(0.86, 0.96, 0.98);

    vec3 col;

    if (l < 0.25) col = p0;
    else if (l < 0.5) col = p1;
    else if (l < 0.75) col = p2;
    else col = p3;

    float gx = 0.90 + 0.10 * sin(v_uv.x * u_resolution.x * 3.1415);
    float gy = 0.94 + 0.06 * sin(v_uv.y * u_resolution.y * 3.1415);

    float column = 0.97 + 0.03 * sin(v_uv.x * u_resolution.x * 1.5708);
    col *= gx * gy * column;

    gl_FragColor = vec4(col, 1.0);
}
