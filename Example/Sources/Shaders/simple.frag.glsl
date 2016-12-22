#ifdef GL_ES
precision mediump float;
#endif

// varying vec3 vVertexColor;
varying vec2 vUV;
varying vec3 vLighting;

uniform sampler2D textureLocation;

void main() {
    vec4 color = texture2D(textureLocation, vUV);
    gl_FragColor = vec4(vLighting * color.rgb, color.a);//1.0);//, 1.0);
}
