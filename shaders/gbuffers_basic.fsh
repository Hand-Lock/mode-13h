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
    // The sky has its own fog: to the render distance (at most 512), solid
    // past it horizontally.
    if (renderStage == MC_RENDER_STAGE_SKY) {
        float end_ = fogSpecial() ? fogEnd : min(far, 512.0);
        f = max(fogRamp(length(viewPos), 0.0, end_),
                step(end_ * float(FOG_END_SCALE), fogCyl(fogPlayer(viewPos))));
    }
#endif
    // Vanilla draws stars and the sunset fan without fog.
    if (renderStage == MC_RENDER_STAGE_STARS || renderStage == MC_RENDER_STAGE_SUNSET) f = 0.0;
    out0 = vec4(mix(vColor.rgb, fogColor, f), vColor.a);
}
