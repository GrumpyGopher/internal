// Name: Cross Eye Depth
// Author: MustardOS
// Version: 1

float luma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    vec2 uv=v_uv;
    vec2 px=1.0/u_resolution;
    vec2 base;

    if (uv.x<0.5)
    base=vec2(uv.x*2.0, uv.y);
    else
    base=vec2((uv.x-0.5)*2.0, uv.y);

    vec3 src=texture2D(u_tex, base).rgb;
    float depth=luma(src);
    float sep=px.x*(3.0+depth*8.0);

    vec2 p;

    if (uv.x<0.5)
    p=base+vec2(sep, 0.0);
    else
    p=base-vec2(sep, 0.0);

    vec3 col=texture2D(u_tex, p).rgb;

    gl_FragColor=vec4(col, 1.0);
}
