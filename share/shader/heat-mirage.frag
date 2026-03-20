// Name: Heat Mirage
// Author: MustardOS
// Version: 1

void main() {
    vec2 uv=v_uv;

    float t=u_time*0.025;
    float rise=uv.y;

    float w1=sin((uv.y*22.0)+t*1.5);
    float w2=sin((uv.y*37.0)-t*0.8);

    float distort=(w1+w2)*0.0025;
    uv.x+=distort*(0.4+rise);
    vec3 col=texture2D(u_tex, uv).rgb;

    gl_FragColor=vec4(col, 1.0);
}