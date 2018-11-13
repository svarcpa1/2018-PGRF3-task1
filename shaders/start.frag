#version 150

in vec3 vertColor;
in vec2 textCoordinates;
in vec4 textCoordinatesDepth;
in vec3 normal;
in vec3 light;
in vec3 viewDirection;
in float distance;

uniform sampler2D textureSampler;
uniform sampler2D textureSamplerDepth;
uniform int modeOfLight, modeOfSurface;

out vec4 outColor; // output from the fragment shader

void main() {

    //handeling acne
    float bias = 0.0005 * tan(acos(dot(normal,light)));

	//per vertex
	if(modeOfLight==0){
	    if(modeOfSurface==0){
            outColor = vec4(vertColor, 1.0);
	    }else if (modeOfSurface==1){
            outColor = texture2D(textureSampler, textCoordinates);
            outColor = outColor * vec4(vertColor, 1.0);
	    }else{
	        outColor = vec4(vertColor, 1.0);
	    }
	}

	else{
        vec4 color = vec4(vertColor,1);
        vec3 ld = -normalize( light );
        vec3 nd = normalize( normal );
        vec3 vd = normalize( -viewDirection );

        vec4 ambient = vec4(0.5,0.5,0.5,1);
        vec4 diffuse = vec4(0.3,0.3,0.3,1);
        vec4 specular = vec4(0.9,0.9,0.9,1);
        vec4 totalAmbient = ambient * vec4(vertColor,1);
        vec4 totalDiffuse = vec4(0.0);
        vec4 totalSpecular = vec4(0.0);

	    //attenuation
        float att=1.0/(0.5 + 0 * distance + 0 * distance * distance);
        float NDotL = max(dot( nd, ld), 0.0 );

        vec3 halfVector = normalize( ld + vd);
        float NDotH = max( 0.0, dot( nd, halfVector ) );

        totalDiffuse = diffuse * vec4(NDotL) * vec4(vertColor,1);
        totalSpecular = specular * ( pow( NDotH, 1*4.0 ) );

        outColor = totalAmbient + att*(totalDiffuse + totalSpecular);

        //float z1=texture(textureSamplerDepth, textCoordinatesDepth.xy).z;
        //float z2=textCoordinatesDepth.z;

        float z1=texture(textureSamplerDepth, textCoordinatesDepth.xy/textCoordinatesDepth.w).r;
        float z2=textCoordinatesDepth.z/textCoordinatesDepth.w;

        //bias for handeling acne
        bool shadow = z1 < z2-bias;
        if(shadow){
            outColor=texture2D(textureSampler, textCoordinates)* totalAmbient;
        }else{
            outColor= texture2D(textureSampler, textCoordinates)*outColor;

        }
    }
} 
