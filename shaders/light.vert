#version 150

in vec2 inPosition; // input from the vertex buffer
in vec2 inTexture;

uniform mat4 viewMat;
uniform mat4 projMat;
uniform float time;
uniform int mode;    //plocha je 0, torus je 1, moje1 je 2

out vec3 vertColor;
out vec2 textCoordinates;

float PI = 3.1415;

float functionForZ(vec2 vec){
    return sin (vec.x * 2 * 3.14 + time);
}

//mine kart
vec3 getTurbine(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;
    float r = 2 + sin(zenith + azimuth);

    float x = r*cos(zenith)*sin(azimuth);
    float y = r*sin(zenith)*sin(azimuth);
    float z = r*cos(azimuth)*0.1*time;

    return vec3(x, y, z);
}
//kart
vec3 getTorus(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;

    float x = 3*cos(azimuth)+cos(zenith)*cos(azimuth);
    float y = 3*sin(azimuth)+cos(zenith)*sin(azimuth);
    float z = sin(zenith);

    return vec3(x, y, z);
}
//mine cylin
vec3 getUfo(vec2 xy){
    float s = PI*xy.x;
	float t = PI*xy.y;
	return vec3(1+sin(t), t*sin(s),t*cos(s));
}
//cylin
vec3 getGoblet(vec2 xy){
    float theta = xy.x * PI;
    float t = xy.y * PI;
	float r = 1+sin(t);

	float x = r*cos(theta);
	float y = r*sin(theta);

	return vec3(x,y,t);
}
// mine spheric
vec3 getSomething(vec2 xy){
    float s = xy.x * PI;
    float t = xy.y * PI;
    float r = sin(t-PI);

    float x = r*sin(t)*cos(s);
    float y = r*sin(t)*sin(s);
    float z = r*cos(t);

    return vec3(x, y, z);
}
//spheric
vec3 getElephant(vec2 xy){
    float s = xy.x * 1.5* PI;
    float t = xy.y * PI;
    float r = 3+cos(4*s);

    float x = r*sin(t)*cos(s);
    float y = r*sin(t)*sin(s);
    float z = r*cos(t);

    return vec3(x, y, z);
}

// normals counted by diffention
vec3 getNormalDiff(vec2 xy){
    vec3 u;
    vec3 v;

    if(mode==1){
        u = getTorus(xy + vec2(0.001,0)) - getTorus(xy - vec2(0.001,0));
        v = getTorus(xy + vec2(0, 0.001)) - getTorus(xy - vec2(0, 0.001));
    }else if(mode==2){
        u = getTurbine(xy + vec2(0.001,0)) - getTurbine(xy - vec2(0.001,0));
        v = getTurbine(xy + vec2(0, 0.001)) - getTurbine(xy - vec2(0, 0.001));
    }else if(mode==3){
        u = getUfo(xy + vec2(0.001,0)) - getUfo(xy - vec2(0.001,0));
        v = getUfo(xy + vec2(0, 0.001)) - getUfo(xy - vec2(0, 0.001));
    }else if(mode==4){
        u = getGoblet(xy + vec2(0.001,0)) - getGoblet(xy - vec2(0.001,0));
        v = getGoblet(xy + vec2(0, 0.001)) - getGoblet(xy - vec2(0, 0.001));
    }else if(mode==5){
        u = getElephant(xy + vec2(0.001,0)) - getElephant(xy - vec2(0.001,0));
        v = getElephant(xy + vec2(0, 0.001)) - getElephant(xy - vec2(0, 0.001));
    }else if(mode==6){
        u = getSomething(xy + vec2(0.001,0)) - getSomething(xy - vec2(0.001,0));
        v = getSomething(xy + vec2(0, 0.001)) - getSomething(xy - vec2(0, 0.001));
    }
    return cross(u,v);
}

//výpočet normál pomocí parciální derivace
vec3 getSphereNormal(vec2 xy){
    float az = xy.x * PI;
    float ze = xy.y * PI/2;
    float r = 1;

    vec3 dx = vec3(-sin(az)*cos(ze)*PI, cos(az)*cos(ze)*PI, 0);
    vec3 dy = vec3(cos(az)*-sin(ze)*PI/2, sin(az)*-sin(ze)*PI/2, cos(ze)*PI/2);

    return cross(dx,dy);
}

void main() {
    vec2 pos = inPosition*2 - 1;
    vec4 pos4;
    vec3 normal;

    //generate plain
    pos4=vec4(pos*3, 2.0, 1.0);
    normal=vec3(pos,2.0);

    if(mode == 1){
        pos4 = vec4(getTorus(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
    }
    if(mode == 2){
        pos4 = vec4(getTurbine(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
    }
    if(mode == 3){
        pos4 = vec4(getUfo(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
    }
    if(mode == 4){
        pos4 = vec4(getGoblet(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
    }
    if(mode == 5){
        pos4 = vec4(getElephant(pos)/4, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
    }
    if(mode == 6){
        pos4 = vec4(getSomething(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
    }

    //this makes that light is with us
    normal = inverse(transpose(mat3(viewMat))) * normal;
	gl_Position = projMat * viewMat * pos4;

	//light
	vec3 lightPos = vec3(5, 5, 1);
	vec3 light = lightPos-(viewMat*pos4).xyz;

	//color
	vertColor = pos4.xyz;
	vertColor = vec3(dot(normalize(normal), normalize(light)));

	//textures
	textCoordinates=inTexture;
}
