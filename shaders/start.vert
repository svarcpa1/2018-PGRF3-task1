#version 150

in vec2 inPosition; //input from the vertex buffer
in vec2 inTexture;
in vec2 inTextureDepth;

uniform mat4 viewMat;
uniform mat4 projMat;
uniform float time;
uniform int modeOfFunction;
uniform int modeOfLight;
uniform vec3 eyePosition;

out vec3 vertColor;
out vec2 textCoordinates;
out vec4 textCoordinatesDepth;
out vec3 normal;
out vec3 light;
out vec3 position;
out vec3 viewDirection;
out vec2 vertInPosition;
out float distance;

float PI = 3.1415;

float functionForZ(vec2 vec){
    return sin (vec.x * 2 * 3.14 + time);
}

//mine kart
vec3 getTrampoline(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;
    float r = 2 + sin(zenith + azimuth);

    float x = sin(zenith)*cos(azimuth);
    float y = 2*sin(azimuth)*sin(zenith);
    float z = cos(zenith)*0.1*time;

    return vec3(x, y, z);
}
//kart
vec3 getSphere(vec2 xy){
    float azimuth = xy.x * PI;
    float zenith = xy.y * PI/2;
    float r = 1;

    float x = cos(azimuth)*cos(zenith)*r;
    float y = sin(azimuth)*cos(zenith)*r;
    float z = sin(zenith)*r;

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
    float t = xy.y * PI *1.5;
	float r = 1+sin(t);

	float x = r*cos(theta)*1.5;
	float y = r*sin(theta)*1.5;

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
    float s = xy.x * PI;
    float t = xy.y * PI;
    float r = 3+cos(4*s);

    float x = r*sin(t)*cos(s);
    float y = r*sin(t)*sin(s);
    float z = r*cos(t);

    return vec3(x, y, z);
}

// normals counted by differention
vec3 getNormalDiff(vec2 xy){
    vec3 u;
    vec3 v;

    if(modeOfFunction==2){
        u = getTrampoline(xy + vec2(0.001,0)) - getTrampoline(xy - vec2(0.001,0));
        v = getTrampoline(xy + vec2(0, 0.001)) - getTrampoline(xy - vec2(0, 0.001));
    }else if(modeOfFunction==3){
        u = getUfo(xy + vec2(0.001,0)) - getUfo(xy - vec2(0.001,0));
        v = getUfo(xy + vec2(0, 0.001)) - getUfo(xy - vec2(0, 0.001));
    }else if(modeOfFunction==4){
        u = getGoblet(xy + vec2(0.001,0)) - getGoblet(xy - vec2(0.001,0));
        v = getGoblet(xy + vec2(0, 0.001)) - getGoblet(xy - vec2(0, 0.001));
    }else if(modeOfFunction==5){
        u = getElephant(xy + vec2(0.001,0)) - getElephant(xy - vec2(0.001,0));
        v = getElephant(xy + vec2(0, 0.001)) - getElephant(xy - vec2(0, 0.001));
    }else if(modeOfFunction==6){
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
    normal = inverse(transpose(mat3(viewMat))) * normal;

    if(modeOfFunction == 1){
        pos4 = vec4(getSphere(pos), 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getSphereNormal(pos);
        normal = inverse(transpose(mat3(viewMat))) * normal;
        normal = (dot(normal,pos4.xyz) > 0.0) ? normal : -normal;
    }
    if(modeOfFunction == 2){
        pos4 = vec4(getTrampoline(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
        normal = inverse(transpose(mat3(viewMat))) * normal;
        normal = (dot(normal,pos4.xyz) > 0.0) ? normal : -normal;
    }
    if(modeOfFunction == 3){
        pos4 = vec4(getUfo(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
        normal = inverse(transpose(mat3(viewMat))) * normal;
        normal = (dot(normal,pos4.xyz) > 0.0) ? normal : -normal;
    }
    if(modeOfFunction == 4){
        pos4 = vec4(getGoblet(pos)/2, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
        normal = inverse(transpose(mat3(viewMat))) * normal;
        normal = (dot(normal,pos4.xyz) > 0.0) ? normal : -normal;
    }
    if(modeOfFunction == 5){
        pos4 = vec4(getElephant(pos)/4, 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
        normal = inverse(transpose(mat3(viewMat))) * normal;
        normal = (dot(normal,pos4.xyz) > 0.0) ? normal : -normal;
    }
    if(modeOfFunction == 6){
        pos4 = vec4(getSomething(pos), 1.0);
        pos4 = vec4(pos4.xy, pos4.z +3.5, pos4.w);
        normal= getNormalDiff(pos);
        normal = inverse(transpose(mat3(viewMat))) * normal;
        normal = (dot(normal,pos4.xyz) > 0.0) ? normal : -normal;
    }


    viewDirection = -pos4.xyz;
	gl_Position = projMat * viewMat * pos4;

	//light
	vec3 lightPos = vec3(5, 5, 1);
	vec3 light = lightPos-(viewMat*pos4).xyz;

	//útlum prostredi
	distance = length(light);

	vec3 eye = normalize(eyePosition - (viewMat*pos4).xyz);
    vertInPosition = inPosition;

	if(modeOfLight==0){
        //color
        vertColor = pos4.xyz;
        vertColor = vec3(dot(normalize(normal), normalize(light)));

        //textures
        textCoordinates=inTexture;
	}else{
        vertColor = pos4.xyz;

        //textures
        textCoordinates=inTexture;

        textCoordinatesDepth = vec4(lightPos,1)*projMat * viewMat * pos4;
        textCoordinatesDepth = vec4(lightPos,1)*pos4;
        textCoordinatesDepth.xyz= pos4.xyz;//spatne
	}
}
