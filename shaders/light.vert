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

//mine katrez
vec3 getTurbine(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;
    float r = 2 + sin(zenith + azimuth);

    float x = r*cos(zenith)*sin(azimuth);
    float y = r*sin(zenith)*sin(azimuth);
    float z = r*cos(azimuth)*0.1*time;

    return vec3(x, y, z);
}
//kartez
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
    float s = xy.x * PI;
    float t = xy.y * PI;

	float r = 1+sin(t);
	float theta = s;

	float x = r*cos(theta);
	float y = r*sin(theta);

	return vec3(x,y,t);
}

//TODO make it one
//výpočet normál pomocí diference
vec3 getUfoNormalDiff(vec2 xy){
    vec3 u = getUfo(xy + vec2(0.001,0)) - getUfo(xy - vec2(0.001,0));
    vec3 v = getUfo(xy + vec2(0, 0.001)) - getUfo(xy - vec2(0, 0.001));
    return cross(u,v);
}

//výpočet normál pomocí diference
vec3 getGobletNormalDiff(vec2 xy){
    vec3 u = getGoblet(xy + vec2(0.001,0)) - getGoblet(xy - vec2(0.001,0));
    vec3 v = getGoblet(xy + vec2(0, 0.001)) - getGoblet(xy - vec2(0, 0.001));
    return cross(u,v);
}

//výpočet normál pomocí diference
vec3 getTorusNormalDiff(vec2 xy){
    vec3 u = getTorus(xy + vec2(0.001,0)) - getTorus(xy - vec2(0.001,0));
    vec3 v = getTorus(xy + vec2(0, 0.001)) - getTorus(xy - vec2(0, 0.001));
    return cross(u,v);
}

//výpočet normál pomocí diference
vec3 getTurbineNormalDiff(vec2 xy){
    vec3 u = getTurbine(xy + vec2(0.001,0)) - getTurbine(xy - vec2(0.001,0));
    vec3 v = getTurbine(xy + vec2(0, 0.001)) - getTurbine(xy - vec2(0, 0.001));
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

    //generuje plochu
    pos4=vec4(pos*3, 2.0, 1.0);
    normal=vec3(pos,2.0);
    //toto dělá, že se světlo točí s náma
    normal = inverse(transpose(mat3(viewMat))) * normal;

    if(mode == 1){
        pos4 = vec4(getTorus(pos)/2, 1.0);
        normal= getTorusNormalDiff(pos);
        //toto dělá, že se světlo točí s náma
        normal = inverse(transpose(mat3(viewMat))) * normal;
    }
    if(mode == 2){
        pos4 = vec4(getTurbine(pos)/2, 1.0);
        normal= getTurbineNormalDiff(pos);
        //toto dělá, že se světlo točí s náma
        normal = inverse(transpose(mat3(viewMat))) * normal;
    }
    if(mode == 3){
        pos4 = vec4(getUfo(pos)/2, 1.0);
        normal= getUfoNormalDiff(pos);
        //toto dělá, že se světlo točí s náma
        normal = inverse(transpose(mat3(viewMat))) * normal;
    }
    if(mode == 4){
        pos4 = vec4(getGoblet(pos)/2, 1.0);
        normal= getGobletNormalDiff(pos);
        //toto dělá, že se světlo točí s náma
        normal = inverse(transpose(mat3(viewMat))) * normal;
    }

	gl_Position = projMat * viewMat * pos4;

	//vypocet osvetleni
	vec3 lightPos = vec3(5, 5, 1);
	vec3 light = lightPos-(viewMat*pos4).xyz;

	//vypocet barvy
	vertColor = pos4.xyz;
	vertColor = vec3(dot(normalize(normal), normalize(light)));

	//textures
	textCoordinates=inTexture;
}
