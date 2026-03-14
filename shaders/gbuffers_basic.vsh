#version 410 compatibility
#include "/shaders.settings"

varying vec4 vColor;

void main() {
    vec4 pos = ftransform();
    gl_Position = pos;
    vColor = gl_Color;
}
