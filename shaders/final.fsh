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

    #if (DOS_PALETTE_BYPASS == 0)
        #if (DOS_PALETTE_256 == 1)
            c = quantize256(c);
        #else
            c = quantizeCube6(c);
        #endif
    #endif

    out0 = vec4(c, 1.0);
}
