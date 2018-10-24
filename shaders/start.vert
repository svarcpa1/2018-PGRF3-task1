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

vec3 getSphere(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;
    float r = 1;

    float x = cos(azimuth)*cos(zenith)*r;
    float y = sin(azimuth)*cos(zenith)*r;
    float z = sin(zenith)*r;

    return vec3(x, y, z);
}

vec3 getTorus(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;
    float r = 1;

    float x = 3*cos(azimuth)+cos(zenith)*cos(azimuth);
    float y = 3*sin(azimuth)+cos(zenith)*sin(azimuth);
    float z = sin(zenith);

    return vec3(x, y, z);
}


vec3 getTorusNormal2(vec2 xy){
    vec3 u = getTorus(xy + vec2(0.001,0)) - getTorus(xy - vec2(0.001,0));
    vec3 v = getTorus(xy + vec2(0, 0.001)) - getTorus(xy - vec2(0, 0.001));
    return cross(u,v);
}


//výpočet normál pomocí diference
vec3 getSphereNormal(vec2 xy){
    vec3 u = getSphere(xy + vec2(0.001,0)) - getSphere(xy - vec2(0.001,0));
    vec3 v = getSphere(xy + vec2(0, 0.001)) - getSphere(xy - vec2(0, 0.001));
    return cross(u,v);
}

//výpočet normál pomocí parciální derivace
vec3 getSphereNormal2(vec2 xy){
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

    if(mode == 1){
        pos4 = vec4(getTorus(pos)/2, 1.0);
        normal= getTorusNormal2(pos);

        //toto dělá, že se světlo točí s náma
        normal = inverse(transpose(mat3(viewMat))) * normal;
    }
    if(mode == 2){
        pos4 = vec4(getSphere(pos), 1.0);
        normal= getSphereNormal2(pos);

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
