// Name: Etched Outline
// Author: MustardOS
// Version: 1

void main() {
    vec2 px=1.0/u_resolution;

    float a=dot(texture2D(u_tex, v_uv+vec2(-px.x, -px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float b=dot(texture2D(u_tex, v_uv+vec2(px.x, -px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float c=dot(texture2D(u_tex, v_uv+vec2(-px.x, px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float d=dot(texture2D(u_tex, v_uv+vec2(px.x, px.y)).rgb, vec3(0.299, 0.587, 0.114));

    float e=abs(a-d)+abs(b-c);

    gl_FragColor=vec4(vec3(e), 1.0);
}
