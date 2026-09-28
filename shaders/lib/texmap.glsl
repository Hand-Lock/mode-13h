// Texture mapping modes (DOS_TEXMAP): 0 perspective-correct, 1 Quake-style
// subdivision, 2 affine. Needs vertex.glsl and common.glsl first. ADR 0007.

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
    // Quake's spans ended at polygon edges; ours are extrapolated past small
    // block faces and, at grazing angles, toward the plane's vanishing line.
    // Cap the deviation from the exact UV so that stays a wobble, not a smear.
    const float MAX_WOBBLE = 2.0;                  // texels
    vec2  e = mix(a.xy / a.z, b.xy / b.z, (x - x0) / S) - uvPersp;
    float n = length(e * vec2(textureSize(gtexture, 0)));
    return uvPersp + e * min(1.0, MAX_WOBBLE / max(n, 1e-6));
#elif (DOS_TEXMAP == 2)
    // Fully affine past 1.5 blocks; closer surfaces fade to correct, so
    // walls you walk into don't smear.
    return mix(uvPersp, uvq.xy, clamp(-viewPos.z / 1.5, 0.0, 1.0));
#else
    return uvPersp;
#endif
}

// texmap() kept inside the face's UV rectangle (min.xy, max.xy), so
// subdivision can't pull in a neighboring sprite at the face's edges.
vec2 texmap(vec2 uvPersp, vec4 rect) {
    vec2 uv = texmap(uvPersp);
#if (DOS_TEXMAP == 1)
    vec2 i = 0.5 / vec2(textureSize(gtexture, 0));  // half a texel inside
    uv = clamp(uv, min(rect.xy + i, uvPersp), max(rect.zw - i, uvPersp));
#endif
    return uv;
}

#endif
