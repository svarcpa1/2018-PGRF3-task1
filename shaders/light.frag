#version 150

in vec4 vertPos;
in vec2 textCoordinates;

uniform sampler2D textureSampler;

out vec4 outColor; // output from the fragment shader

void main() {
    //outColor.rgb = vec3(gl_FragCoord.z);
    outColor.rgb = vec3(vertPos.z/vertPos.w + 1)/2;
} 
