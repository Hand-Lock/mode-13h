#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/fog.glsl"

uniform int renderStage;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    float f = fogFactor(viewPos);
#if MC_VERSION >= 12106
    // The sky and the void below the horizon have their own fog: to the
    // render distance, solid past it horizontally. Vanilla caps it at 512
    // from 1.21.11; far never exceeds 512, so min() is right on 1.21.6+.
    if (renderStage == MC_RENDER_STAGE_SKY || renderStage == MC_RENDER_STAGE_VOID) {
        vec3 p = fogPlayer(viewPos);
        // Vanilla measures the void before lifting it 12 blocks.
        if (renderStage == MC_RENDER_STAGE_VOID) p.y -= 12.0;
        float end_ = fogSpecial() ? fogEnd : min(far, 512.0);
        f = max(fogRamp(length(p), 0.0, end_),
                step(end_ * float(FOG_END_SCALE), fogCyl(p)));
    }
#endif
    // Vanilla draws stars and the sunset fan without fog.
    if (renderStage == MC_RENDER_STAGE_STARS || renderStage == MC_RENDER_STAGE_SUNSET) f = 0.0;
    out0 = vec4(mix(vColor.rgb, fogColor, f), vColor.a);
}
