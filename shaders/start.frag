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
uniform int modeOfLight;

out vec4 outColor; // output from the fragment shader

void main() {

	//per vertex
	if(modeOfLight==0){
	    outColor = texture2D(textureSampler, textCoordinates);
	    outColor = outColor * vec4(vertColor, 1.0);
	}

	else{
        vec4 color = vec4(vertColor,1);
        vec3 ld = normalize( light );
        vec3 nd = normalize( normal );
        vec3 vd = normalize( viewDirection );

        vec4 ambient = vec4(0.1,0.1,0.1,1);
        vec4 diffuse = vec4(0.1,0.1,0.1,1);
        vec4 specular = vec4(0.8,0.8,0.8,1);
        vec4 totalAmbient = ambient * vec4(vertColor,1);
        vec4 totalDiffuse = vec4(0.0);
        vec4 totalSpecular = vec4(0.0);

        //útlum
        float att=1.0/(1.0 + 0 * distance + 0 * distance * distance);
        float NDotL = max(dot( nd, ld), 0.0 );

        vec3 halfVector = normalize( ld + vd);
        float NDotH = max( 0.0, dot( nd, halfVector ) );

        totalDiffuse = diffuse * vec4(NDotL) * vec4(vertColor,1);
        totalSpecular = specular * ( pow( NDotH, 1*4.0 ) );

        outColor = totalAmbient + att*(totalDiffuse + totalSpecular);

        float z1=texture(textureSamplerDepth, textCoordinatesDepth.xy/textCoordinatesDepth.w).r;
        float z2=textCoordinatesDepth.z/textCoordinatesDepth.w;

        bool shadow = z1 < z2 - 0.1;
        if(shadow){
            outColor=texture2D(textureSampler, textCoordinates)* totalAmbient;

        }else{
            outColor= texture2D(textureSampler, textCoordinates)*outColor;
        }
    }
} 
