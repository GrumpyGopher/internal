// Name: Frosted Glass
// Author: MustardOS
// Version: 1

float hash(vec2 p) {
    p=fract(p*vec2(123.34, 345.45));
    p+=dot(p, p+34.23);

    return fract(p.x*p.y);
}

void main() {
    vec2 px=1.0/u_resolution;
    vec2 off=(vec2(hash(v_uv), hash(v_uv+0.1))-0.5)*px*8.0;
    vec3 col=texture2D(u_tex, v_uv+off).rgb;

    gl_FragColor=vec4(col, 1.0);
}
