// /shaders/final.fsh
#version 410 compatibility
#include "/shaders.settings"
#include "/lib/common.glsl"
#include "/lib/palette.glsl"

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main(){
    // Use the actual view size to avoid any internal-size mismatch.
    vec2 screen = vec2(viewWidth, viewHeight);

    // Snap to a 4x4 macro-pixel, but sample a *real* texel center in that block
    // (top-left texel): center is (i + 0.5), not (i + 2.0).
    ivec2 cell = ivec2(gl_FragCoord.xy) / DOS_SCALE;
    vec2  srcPx = vec2(cell * DOS_SCALE) + vec2(0.5);
    vec2  uv    = srcPx / screen;

    vec3 c = texture(colortex0, uv).rgb;

    // Optional grading + palette reduction (bypass when DOS_PALETTE_BYPASS == 1)
    #if (DOS_PALETTE_BYPASS == 0)
        c = grade(c);
        #if (DOS_PALETTE_256 == 1)
            c = quantize256(c);
        #else
            c = quantizeCube6(c);
        #endif
    #endif

    out0 = vec4(c, 1.0);
}
