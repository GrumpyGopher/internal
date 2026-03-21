// Name: Pop Art
// Author: MustardOS
// Version: 1

float luma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    vec2 uv=v_uv;
    vec2 q=floor(uv*2.0);
    vec2 p=fract(uv*2.0);
    vec3 src=texture2D(u_tex, p).rgb;

    float y=luma(src);

    vec3 base=vec3(y);
    y=floor(y*4.0)/4.0;
    vec3 tint;

    if (q.x<0.5 && q.y<0.5) tint=vec3(1.0, 0.2, 0.2);
    else if (q.x>0.5 && q.y<0.5) tint=vec3(0.2, 1.0, 0.2);
    else if (q.x<0.5 && q.y>0.5) tint=vec3(0.2, 0.4, 1.0);
    else tint=vec3(1.0, 1.0, 0.2);

    vec3 col=base*tint*1.4;

    gl_FragColor=vec4(col, 1.0);
}
