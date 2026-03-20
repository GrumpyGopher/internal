// Name: Game Boy - Pocket
// Author: MustardOS
// Version: 1

void main() {
    vec3 c = texture2D(u_tex, v_uv).rgb;

    float l = dot(c, vec3(0.299, 0.587, 0.114));

    vec3 p0 = vec3(0.05, 0.10, 0.12);
    vec3 p1 = vec3(0.28, 0.42, 0.45);
    vec3 p2 = vec3(0.55, 0.70, 0.72);
    vec3 p3 = vec3(0.82, 0.94, 0.96);

    vec3 col;

    if (l < 0.25) col = p0;
    else if (l < 0.5) col = p1;
    else if (l < 0.75) col = p2;
    else col = p3;

    float gx = 0.92 + 0.08 * sin(v_uv.x * u_resolution.x * 3.1415);
    float gy = 0.94 + 0.06 * sin(v_uv.y * u_resolution.y * 3.1415);

    col *= gx * gy;

    gl_FragColor = vec4(col, 1.0);
}
