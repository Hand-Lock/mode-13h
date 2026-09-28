// Texture mapping modes (DOS_TEXMAP): 0 perspective-correct, 1 Quake-style
// subdivision, 2 affine. Needs vertex.glsl first. ADR 0007.

#ifndef TEXMAP_GLSL
#define TEXMAP_GLSL

vec2 texmap(vec2 uvPersp) {
#if (DOS_TEXMAP == 1)
    // uvq = (u/w, v/w, 1/w) is linear in screen space. Compute the exact UV
    // at both ends of this pixel's span (DOS_SPAN output pixels, aligned to
    // the final cells) and interpolate linearly in between.
    const float S = float(DOS_SPAN * DOS_SCALE);
    float x  = gl_FragCoord.x;
    float x0 = floor(x / S) * S;
    vec3  d  = dFdx(uvq);
    vec3  a  = uvq + d * (x0 - x);
    vec3  b  = a + d * S;
    // An extrapolated end behind the eye has no valid UV.
    if (min(a.z, b.z) <= 1e-6) return uvPersp;
    return mix(a.xy / a.z, b.xy / b.z, (x - x0) / S);
#elif (DOS_TEXMAP == 2)
    // Fully affine past 1.5 blocks; closer surfaces fade to correct, so
    // walls you walk into don't smear.
    return mix(uvPersp, uvq.xy, clamp(-viewPos.z / 1.5, 0.0, 1.0));
#else
    return uvPersp;
#endif
}

#endif
