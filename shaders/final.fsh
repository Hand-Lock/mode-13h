#version 410 compatibility
#include "/shaders.settings"
#include "/lib/palette.glsl"

uniform sampler2D colortex0;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    // One sample per DOS_SCALE cell: its top-left texel.
    ivec2 cell = ivec2(gl_FragCoord.xy) / DOS_SCALE;
    vec3 c = texelFetch(colortex0, cell * DOS_SCALE, 0).rgb;
    out0 = vec4(palettize(c), 1.0);
}
