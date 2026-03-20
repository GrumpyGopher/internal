// Name: Pixels
// Author: MustardOS
// Version: 1

void main() {
    float size=128.0;

    vec2 grid=vec2(size, size*(u_resolution.y/u_resolution.x));
    vec2 uv=floor(v_uv*grid)/grid;
    vec3 col=texture2D(u_tex, uv).rgb;

    gl_FragColor=vec4(col, 1.0);
}
