#version 150

in vec3 vertColor;
in vec2 textCoordinates;

uniform sampler2D textureSampler;

out vec4 outColor; // output from the fragment shader

void main() {
	outColor = texture2D(textureSampler, textCoordinates);
	outColor = outColor * vec4(vertColor, 1.0);
} 
