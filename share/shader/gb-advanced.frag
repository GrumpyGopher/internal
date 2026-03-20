// Name: Game Boy - Advanced
// Author: MustardOS
// Version: 1

float luma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float hash(vec2 p){
    p=fract(p*vec2(123.34, 345.45));
    p+=dot(p, p+34.23);

    return fract(p.x*p.y);
}

void main() {
    vec2 px=1.0/u_resolution;

    vec3 c0=texture2D(u_tex, v_uv).rgb;
    vec3 c1=texture2D(u_tex, v_uv-vec2(px.x*1.2, 0.0)).rgb;
    vec3 col=mix(c0, c1, 0.22);

    float y=luma(col);

    col=mix(vec3(y), col, 0.82);
    col*=vec3(0.88, 0.93, 0.86);

    float gx=0.91+0.09*sin(v_uv.x*u_resolution.x*3.1415);
    float gy=0.95+0.05*sin(v_uv.y*u_resolution.y*3.1415);
    float column=0.975+0.025*sin(v_uv.x*u_resolution.x*1.5708);

    col*=gx*gy*column;
    float alpha=smoothstep(0.72, 1.0, y)*0.28;

    vec3 backing=vec3(0.72, 0.78, 0.62);
    float grain=(hash(v_uv*u_resolution)-0.5)*0.035;
    backing+=grain;

    col=mix(col, backing, alpha);

    gl_FragColor=vec4(col, 1.0);
}
