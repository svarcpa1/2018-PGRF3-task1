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
    //float bias = 0.005 * tan(acos(dot(normal,light)));

    //vec4 baseColor = texture(textureSampler,textCoordinates);
    vec4 baseColor = texture(textureSampler, textCoordinates);

	//per vertex
	if(modeOfLight==0){
	    if(modeOfSurface==0){
            outColor = vec4(vertColor, 1.0);

            vec3 textCoordinatesDepthTmp;
            textCoordinatesDepthTmp = (textCoordinatesDepth.xyz/textCoordinatesDepth.w + 1.)/2.;
            if (texture(textureSamplerDepth, textCoordinatesDepthTmp.xy).z < textCoordinatesDepthTmp.z-0.0005){
                outColor = outColor*0.5;
            }else{
                outColor = outColor;
            }

	    }else if (modeOfSurface==1){
            outColor = texture2D(textureSampler, textCoordinates);
            outColor = outColor * vec4(vertColor, 1.0);

            vec3 textCoordinatesDepthTmp;
            textCoordinatesDepthTmp = (textCoordinatesDepth.xyz/textCoordinatesDepth.w + 1.)/2.;
            if (texture(textureSamplerDepth, textCoordinatesDepthTmp.xy).z < textCoordinatesDepthTmp.z-0.0005){
                outColor = outColor*0.5;
            }else{
                outColor = outColor;
            }
	    }else{
	        outColor = vec4(vertColor, 1.0);

            vec3 textCoordinatesDepthTmp;
            textCoordinatesDepthTmp = (textCoordinatesDepth.xyz/textCoordinatesDepth.w + 1.)/2.;
	        if (texture(textureSamplerDepth, textCoordinatesDepthTmp.xy).z < textCoordinatesDepthTmp.z-0.0005){
                outColor = outColor*0.5;
            }else{
                outColor = outColor;
            }
	    }
	}

	else{
        //vec4 color = vec4(vertColor,1);
        vec3 ld = normalize( light );
        vec3 nd = normalize( normal );
        vec3 vd = normalize( viewDirection );

        vec4 ambient = vec4(0.3,0.3,0.3,1);
        vec4 diffuse = vec4(0.5,0.5,0.5,1);
        vec4 specular = vec4(0.8,0.8,0.8,1);
        vec4 totalAmbient = ambient * baseColor;
        vec4 totalDiffuse = vec4(0.0);
        vec4 totalSpecular = vec4(0.0);

	    //attenuation
        float att=1.0/(0.1 + 0.2 * distance + 0.1 * distance * distance);

        float NDotL = max(dot( nd, ld), 0.0 );
        vec3 reflection = normalize(((2.0 * nd)*NDotL)-ld);
        float RDotV = max(0.0, dot(reflection, vd));
        vec3 halfVector = normalize( ld + vd);
        float NDotH = max(0.0, dot(nd, halfVector));

        totalDiffuse = diffuse * NDotL * baseColor;
        totalSpecular = specular * (pow(NDotH, 16));

        outColor = totalAmbient + (totalDiffuse + totalSpecular);

        vec3 textCoordinatesDepthTmp;
        textCoordinatesDepthTmp = (textCoordinatesDepth.xyz/textCoordinatesDepth.w + 1.)/2.;

        //if(shadow)...
        if (texture(textureSamplerDepth, textCoordinatesDepthTmp.xy).z < textCoordinatesDepthTmp.z-0.0005){
            outColor=texture(textureSampler, textCoordinates)*totalAmbient;
        }else{
            outColor=texture(textureSampler, textCoordinates)*outColor;
        }
    }
} 
