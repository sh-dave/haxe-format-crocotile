#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 aVertexNormal;
attribute vec3 aVertexPosition;
attribute vec2 aVertexUV;

uniform mat4 uNormalMatrix;
uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

varying vec3 vLighting;
varying vec2 vUV;
// varying vec3 vVertexColor;

void main() {
	gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
	vec3 ambientLight = vec3(0.3, 0.3, 0.3);
	vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
	vec3 directionalVector = vec3(0.85, 0.8, -0.75);
	vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
	float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
	vLighting = ambientLight + (directionalLightColor * directional);
	vUV = aVertexUV;
	//vVertexColor = aVertexColor;
}