#version 100

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D textureLocation;

varying vec2 fragmentUV;
varying vec4 fragmentColor;

void kore() {
	vec4 color = texture2D(textureLocation, fragmentUV) * fragmentColor;
	color.rgb *= fragmentColor.a;
	gl_FragColor = color;
}
