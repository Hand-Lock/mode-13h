#version 410 compatibility
#include "/shaders.settings"

attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec2 mc_midTexCoord;
attribute vec3 at_midBlock;

uniform mat4  gbufferModelViewInverse;
uniform ivec2 atlasSize;

varying vec2 texcoord;
noperspective varying vec2 texcoord_np;
varying vec2 lmcoord;
varying vec4 vColor;
flat out int noAffine;

// Billboard rotation: projects vertex offset onto a camera-facing plane.
// Each variant operates on a different pair of world axes.
void billboardXZ(inout vec4 pos, vec2 offset, vec2 center) {
    vec2 v = normalize(gbufferModelViewInverse[2].xz);
    pos.xz = mat2(v.y, -v.x, v.x, v.y) * offset + center;
}
void billboardYZ(inout vec4 pos, vec2 offset, vec2 center) {
    vec2 v = normalize(gbufferModelViewInverse[2].yz);
    pos.yz = mat2(v.y, -v.x, v.x, v.y) * offset + center;
}
void billboardXY(inout vec4 pos, vec2 offset, vec2 center) {
    vec2 v = normalize(gbufferModelViewInverse[2].xy);
    pos.xy = mat2(v.y, -v.x, v.x, v.y) * offset + center;
}

void main() {
    int blockID = int(mc_Entity.x + 0.5);

    texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    texcoord_np = texcoord;
    lmcoord     = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor      = gl_Color;

    // Disable affine mapping on all billboard geometry
    noAffine = 0;
    if ((blockID >= 10950 && blockID <= 10955) ||
        (blockID >= 10957 && blockID <= 10959) ||
        (blockID >= 10961 && blockID <= 10964) ||
        (blockID >= 10965 && blockID <= 10968) ||
        (blockID >= 10970 && blockID <= 10973)) {
        noAffine = 1;
    }
    #if (FLATTER_SIGNS == 1)
        if (blockID == 10956) noAffine = 1;
    #endif
    #if (BILLY_BOARDING == 1)
        if (blockID == 10990) noAffine = 1;
    #endif

    vec4 vertexPos = gl_Vertex;

    // ---- Cross-model flora (10950-10952) ----
    if ((blockID == 10950 || blockID == 10951 || blockID == 10952) && gl_Normal.y == 0.0) {
        // Keep one face of the cross pair to avoid double-layer artifacts
        if (sign(gl_Normal.xz) != vec2(1.0, 1.0)) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2((texcoord.x - mc_midTexCoord.x) * sign(at_tangent.w) * float(atlasSize.x) / 16.0, 0.0);
        vec2 center = vertexPos.xz - 1.8 * offset.x * normalize(at_tangent).xz * sign(at_tangent.w);
        billboardXZ(vertexPos, offset, center);

        // Hanging propagule: flip UV vertically
        if (blockID == 10952) {
            texcoord.y -= 2.0 * (texcoord.y - mc_midTexCoord.y);
        }
    }

    // ---- Signs: standing and hanging (10956) ----
    #if (FLATTER_SIGNS == 1)
    else if (blockID == 10956) {
        vec3 blockCenter = vertexPos.xyz + at_midBlock / 64.0;
        float side = (texcoord.x - mc_midTexCoord.x >= 0.0) ? 1.0 : -1.0;
        vec2 offset = vec2(0.45 * side, 0.0);
        vec2 center = blockCenter.xz;
        billboardXZ(vertexPos, offset, center);
    }
    #endif

    // ---- Amethyst: up/down facing (10953) ----
    else if (blockID == 10953) {
        if (sign(gl_Normal.xz) != vec2(1.0, 1.0)) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2(0.5 * sign(at_midBlock.z) * sign(at_tangent.w), 0.0);
        vec2 center = vertexPos.xz - 0.905 * sign(texcoord.x - mc_midTexCoord.x) * normalize(at_tangent).xz;
        billboardXZ(vertexPos, offset, center);
    }

    // ---- Amethyst: east/west facing (10954) ----
    else if (blockID == 10954) {
        if (sign(gl_Normal.yz) != vec2(1.0, 1.0)) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2(0.5 * -sign(at_midBlock.y), 0.0);
        vec2 center = vertexPos.yz + at_midBlock.yz / 64.0;
        billboardYZ(vertexPos, offset, center);
    }

    // ---- Amethyst: north/south facing (10955) ----
    else if (blockID == 10955) {
        if (sign(gl_Normal.xy) != vec2(1.0, 1.0)) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2(0.5 * -sign(at_midBlock.x), 0.0);
        vec2 center = vertexPos.xy + at_midBlock.xy / 64.0;
        billboardXY(vertexPos, offset, center);
    }

    // ---- Chain: axis X (10957) ----
    else if (blockID == 10957) {
        vec2 offset = vec2(1.5 / 16.0 * sign(texcoord.x - mc_midTexCoord.x), 0.0);
        vec2 center = vertexPos.yz + at_midBlock.yz / 64.0;
        billboardYZ(vertexPos, offset, center);
    }

    // ---- Chain: axis Y (10958) ----
    else if (blockID == 10958) {
        vec2 offset = vec2(1.5 / 16.0 * sign(texcoord.x - mc_midTexCoord.x), 0.0);
        vec2 center = vertexPos.xz + at_midBlock.xz / 64.0;
        billboardXZ(vertexPos, offset, center);
    }

    // ---- Chain: axis Z (10959) ----
    else if (blockID == 10959) {
        vec2 offset = vec2(1.5 / 16.0 * sign(texcoord.x - mc_midTexCoord.x), 0.0);
        vec2 center = vertexPos.xy + at_midBlock.xy / 64.0;
        billboardXY(vertexPos, offset, center);
    }

    // ---- Floor torches (10961-10963) ----
    else if (blockID >= 10961 && blockID <= 10963) {
        if (gl_Normal.y != 0.0) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2((texcoord.x - mc_midTexCoord.x) * float(atlasSize.x) / 16.0, 0.0);
        vec2 center = vertexPos.xz + at_midBlock.xz / 64.0;
        billboardXZ(vertexPos, offset, center);
    }

    // ---- Bamboo stalk (10964) ----
    else if (blockID == 10964) {
        if (gl_Normal.z < 0.5 || gl_Normal.x < 0.0) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset, center;
        if (gl_Normal.z > 0.9) {
            offset = vec2(1.5 / 16.0 * sign(texcoord.x - mc_midTexCoord.x), 0.0);
            center = vertexPos.xz + vec2(-0.09 * sign(texcoord.x - mc_midTexCoord.x), -1.5 / 16.0);
        } else {
            offset = vec2(0.5 * sign(texcoord.x - mc_midTexCoord.x), 0.0);
            center = vertexPos.xz - 0.905 * sign(texcoord.x - mc_midTexCoord.x) * normalize(at_tangent).xz;
        }
        billboardXZ(vertexPos, offset, center);
    }

    // ---- Lanterns: regular and soul (10965-10968) ----
    else if (blockID >= 10965 && blockID <= 10968) {
        if (gl_Normal.y != 0.0) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2((texcoord.x - mc_midTexCoord.x) * float(atlasSize.x) / 16.0, 0.0);
        vec2 center = vertexPos.xz + at_midBlock.xz / 64.0;
        billboardXZ(vertexPos, offset, center);
    }

    // ---- Wall torches (10970-10973) ----
    else if (blockID >= 10970 && blockID <= 10973) {
        if (gl_Normal.y > -0.1 || gl_Normal.y < -0.7) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2(0.5 * sign(texcoord.x - mc_midTexCoord.x), 0.0);
        vec2 center = vertexPos.xz + (at_midBlock.xz / 64.0) * sign(abs(gl_Normal.zx));
        billboardXZ(vertexPos, offset, center);
    }

    // ---- Billy Boarding cross-model blocks (10990) ----
    #if (BILLY_BOARDING == 1)
    else if (blockID == 10990 && gl_Normal.y == 0.0) {
        if (sign(gl_Normal.xz) != vec2(1.0, 1.0)) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }
        vec2 offset = vec2((texcoord.x - mc_midTexCoord.x) * sign(at_tangent.w) * float(atlasSize.x) / 16.0, 0.0);
        vec2 center = vertexPos.xz - 1.8 * offset.x * normalize(at_tangent).xz * sign(at_tangent.w);
        billboardXZ(vertexPos, offset, center);
    }
    #endif

    gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * vertexPos);
}
