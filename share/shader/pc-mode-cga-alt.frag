// Name: PC Mode - CGA Alt.
// Author: MustardOS
// Version: 1

void main() {
    vec3 c=texture2D(u_tex, v_uv).rgb;
    float l=dot(c, vec3(.299, .587, .114));
    vec3 col;

    if (l<0.25) col=vec3(0.0, 0.0, 0.0);
    else if (l<0.5) col=vec3(0.0, 1.0, 0.0);
    else if (l<0.75) col=vec3(1.0, 0.0, 0.0);
    else col=vec3(1.0, 1.0, 0.0);

    gl_FragColor=vec4(col, 1.0);
}
