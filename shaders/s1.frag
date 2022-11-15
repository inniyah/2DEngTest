#version 330 core

//out vec4 FragColor;

in vec2 texCoord;

uniform sampler2D tex0;

void main() {
	vec4 Color = texture(tex0, texCoord).rgba;
	if (Color.a<0.9) {
		discard;
	}
	gl_FragColor = Color;
}
