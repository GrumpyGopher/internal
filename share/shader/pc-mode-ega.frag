// Name: PC Mode - EGA
// Author: MustardOS
// Version: 1

vec3 ega0=vec3(0.0, 0.0, 0.0);
vec3 ega1=vec3(0.0, 0.0, 0.6667);
vec3 ega2=vec3(0.0, 0.6667, 0.0);
vec3 ega3=vec3(0.0, 0.6667, 0.6667);
vec3 ega4=vec3(0.6667, 0.0, 0.0);
vec3 ega5=vec3(0.6667, 0.0, 0.6667);
vec3 ega6=vec3(0.6667, 0.3333, 0.0);
vec3 ega7=vec3(0.6667, 0.6667, 0.6667);
vec3 ega8=vec3(0.3333, 0.3333, 0.3333);
vec3 ega9=vec3(0.3333, 0.3333, 1.0);
vec3 ega10=vec3(0.3333, 1.0, 0.3333);
vec3 ega11=vec3(0.3333, 1.0, 1.0);
vec3 ega12=vec3(1.0, 0.3333, 0.3333);
vec3 ega13=vec3(1.0, 0.3333, 1.0);
vec3 ega14=vec3(1.0, 1.0, 0.3333);
vec3 ega15=vec3(1.0, 1.0, 1.0);

vec3 pick(vec3 c) {
    vec3 best=ega0;
    float d=dot(c-ega0, c-ega0);
    float t;

    t=dot(c-ega1, c-ega1);
    if (t<d){ d=t;best=ega1; }

    t=dot(c-ega2, c-ega2);
    if (t<d){ d=t;best=ega2; }

    t=dot(c-ega3, c-ega3);
    if (t<d){ d=t;best=ega3; }

    t=dot(c-ega4, c-ega4);
    if (t<d){ d=t;best=ega4; }

    t=dot(c-ega5, c-ega5);
    if (t<d){ d=t;best=ega5; }

    t=dot(c-ega6, c-ega6);
    if (t<d){ d=t;best=ega6; }

    t=dot(c-ega7, c-ega7);
    if (t<d){ d=t;best=ega7; }

    t=dot(c-ega8, c-ega8);
    if (t<d){ d=t;best=ega8; }

    t=dot(c-ega9, c-ega9);
    if (t<d){ d=t;best=ega9; }

    t=dot(c-ega10, c-ega10);
    if (t<d){ d=t;best=ega10; }

    t=dot(c-ega11, c-ega11);
    if (t<d){ d=t;best=ega11; }

    t=dot(c-ega12, c-ega12);
    if (t<d){ d=t;best=ega12; }

    t=dot(c-ega13, c-ega13);
    if (t<d){ d=t;best=ega13; }

    t=dot(c-ega14, c-ega14);
    if (t<d){ d=t;best=ega14; }

    t=dot(c-ega15, c-ega15);
    if (t<d){ d=t;best=ega15; }

    return best;
}

void main() {
    vec3 c=texture2D(u_tex, v_uv).rgb;

    gl_FragColor=vec4(pick(c), 1.0);
}
