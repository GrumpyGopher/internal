// Name: PC Mode - VGA
// Author: MustardOS
// Version: 1

vec3 cube(vec3 c) {
    return floor(c*5.0+0.5)/5.0;
}

vec3 grey(float g) {
    float v=floor(g*23.0+0.5)/23.0;
    return vec3(v);
}

void main() {
    vec3 c=texture2D(u_tex, v_uv).rgb;
    float l=dot(c, vec3(.299, .587, .114));
    vec3 col=mix(cube(c), grey(l), step(.85, l));

    gl_FragColor=vec4(col, 1.0);
}
