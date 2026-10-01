#version 410 compatibility
#include "/shaders.settings"
#define VSH
#include "/lib/vertex.glsl"

attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec2 mc_midTexCoord;
attribute vec3 at_midBlock;

uniform mat4  gbufferModelView;
uniform mat4  gbufferModelViewInverse;
uniform vec3  cameraPosition;
uniform ivec2 atlasSize;
uniform int   renderStage;

flat out int noAffine;
flat out int billy;
out vec4 uvRect;

// Drop this vertex off screen (for the faces a billboard doesn't keep).
#define CULL { gl_Position = vec4(-10.0, -10.0, -10.0, 1.0); return; }

// Billboard rotation in the plane of two world axes: the point `offset`
// blocks from `center` along the camera's right vector. `fwd` holds the
// camera forward vector's components on those two axes.
vec2 faceCamera(vec2 fwd, float offset, vec2 center) {
    vec2 v = normalize(fwd);
    return center + offset * vec2(v.y, -v.x);
}

// One face of a cross model: its center (xy) on the two horizontal axes of
// `p`, and this vertex's offset from it along the face (z). `t` is the
// tangent in the same space as `p`.
vec3 crossFace(vec2 p, vec2 uv, vec4 t) {
    float offset = (uv.x - mc_midTexCoord.x) * sign(t.w) * float(atlasSize.x) / 16.0;
    return vec3(p - 1.8 * offset * normalize(t).xz * sign(t.w), offset);
}

void main() {
    int id = int(mc_Entity.x + 0.5);
#if GOLDEN_DAYS == 1
    // Golden Days: seagrass is a plain cross, and the hanging propagule is
    // a sapling cross already turned upside down (no UV flip).
    if (id == 10952 || id == 10962) id = 10950;
#endif
    vec2 uv = vertexUV();
    vec4 pos = gl_Vertex;
    vec3 fwd = gbufferModelViewInverse[2].xyz;
    vec3 mid = at_midBlock / 64.0;
    float side = sign(uv.x - mc_midTexCoord.x);
    float layer = 0.0;

    // Billboards stay perspective-correct.
    noAffine = int((id >= 10950 && id < 10990 && (id != 10956 || FLATTER_SIGNS == 1)) ||
                   (id == 10990 && BILLY_BOARDING == 1));
    billy = int(id == 10990);

#ifdef MC_RENDER_STAGE_ENTITIES
    // ---- Falling blocks ----
    // Drawn here through gbuffers_block in the entity stage, without a block
    // ID or at_midBlock, and not in world-aligned model space. Billboard their
    // diagonal faces (Billy Boarding anvils, pointed dripstone) in player space.
    if (renderStage == MC_RENDER_STAGE_ENTITIES) {
        mat3 toPlayer = mat3(gbufferModelViewInverse) * mat3(gl_ModelViewMatrix);
        vec3 n = toPlayer * gl_Normal;
        if (abs(n.y) < 0.1 && all(greaterThan(abs(n.xz), vec2(0.5)))) {
            if (sign(n.xz) != vec2(1.0)) CULL
            vec3 p = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
            vec3 f = crossFace(p.xz, uv, vec4(toPlayer * at_tangent.xyz, at_tangent.w));
            p.xz = faceCamera(fwd.xz, f.z, f.xy);
            noAffine = 1;
            emitView((gbufferModelView * vec4(p, 1.0)).xyz, uv);
            return;  // uvRect is unused when noAffine
        }
    }
#endif

    // ---- Cross models: flora, hanging propagule, Billy Boarding ----
    // Billy Boarding: only diagonal faces; axis-aligned ones are drawn as they are.
    if ((id == 10950 || id == 10952 ||
         (id == 10990 && BILLY_BOARDING == 1 && all(greaterThan(abs(gl_Normal.xz), vec2(0.5)))))
        && gl_Normal.y == 0.0) {
        // Keep one face of the cross pair to avoid double-layer artifacts
        if (sign(gl_Normal.xz) != vec2(1.0)) CULL
        vec3 f = crossFace(pos.xz, uv, at_tangent);
        float offset = f.z;
        vec2 center = f.xy;
        // Billy Boarding: turn around the block's axis, taken from the block
        // grid (at_midBlock is truncated to 1/64 block, it only picks the
        // block). The face's offset from it along its normal, in 0.05 px
        // model steps (rescaled by the 45° cross), is its depth rank.
        if (id == 10990) {
            vec2 cam = fract((gbufferModelViewInverse * gl_ModelViewMatrix[3]).xz + cameraPosition.xz);
            center = floor(pos.xz + mid.xz + cam) + 0.5 - cam;
            layer = round(dot(pos.xz - center, normalize(gl_Normal.xz)) * 16.0 / (0.05 * sqrt(2.0)));
            offset = round(offset * 16.0) / 16.0;
        }
        pos.xz = faceCamera(fwd.xz, offset, center);

        // Hanging propagule: flip UV vertically
        if (id == 10952) uv.y = 2.0 * mc_midTexCoord.y - uv.y;
    }

    // ---- Signs: standing and hanging (Flatter Signs) ----
    else if (id == 10956 && FLATTER_SIGNS == 1) {
        float s = (uv.x - mc_midTexCoord.x >= 0.0) ? 1.0 : -1.0;
        pos.xz = faceCamera(fwd.xz, 0.45 * s, pos.xz + mid.xz);
    }

    // ---- Amethyst by facing: up/down, east/west, north/south ----
    else if (id == 10953) {
        if (sign(gl_Normal.xz) != vec2(1.0)) CULL
        vec2 center = pos.xz - 0.905 * side * normalize(at_tangent).xz;
        pos.xz = faceCamera(fwd.xz, 0.5 * sign(at_midBlock.z) * sign(at_tangent.w), center);
    }
    else if (id == 10954) {
        if (sign(gl_Normal.yz) != vec2(1.0)) CULL
        pos.yz = faceCamera(fwd.yz, -0.5 * sign(at_midBlock.y), pos.yz + mid.yz);
    }
    else if (id == 10955) {
        if (sign(gl_Normal.xy) != vec2(1.0)) CULL
        pos.xy = faceCamera(fwd.xy, -0.5 * sign(at_midBlock.x), pos.xy + mid.xy);
    }

    // ---- Chains by axis: X, Y, Z ----
    else if (id == 10957) pos.yz = faceCamera(fwd.yz, 1.5 / 16.0 * side, pos.yz + mid.yz);
    else if (id == 10958) pos.xz = faceCamera(fwd.xz, 1.5 / 16.0 * side, pos.xz + mid.xz);
    else if (id == 10959) pos.xy = faceCamera(fwd.xy, 1.5 / 16.0 * side, pos.xy + mid.xy);

    // ---- Floor torches and lanterns ----
    else if (id == 10961) {
        if (gl_Normal.y != 0.0) CULL
        float offset = (uv.x - mc_midTexCoord.x) * float(atlasSize.x) / 16.0;
        pos.xz = faceCamera(fwd.xz, offset, pos.xz + mid.xz);
    }

    // ---- Seagrass: four axis-aligned planes in a # ----
    // Keep the south face of the z = 4 plane, billboarded on the block's center.
    else if (id == 10962) {
        if (gl_Normal.z < 0.5 || mid.z < 0.0) CULL
        float offset = (uv.x - mc_midTexCoord.x) * float(atlasSize.x) / 16.0;
        pos.xz = faceCamera(fwd.xz, offset, pos.xz + mid.xz);
    }

    // ---- Bamboo stalk ----
    else if (id == 10964) {
        if (gl_Normal.z < 0.5 || gl_Normal.x < 0.0) CULL
        if (gl_Normal.z > 0.9) {
            pos.xz = faceCamera(fwd.xz, 1.5 / 16.0 * side, pos.xz + vec2(-0.09 * side, -1.5 / 16.0));
        } else {
            pos.xz = faceCamera(fwd.xz, 0.5 * side, pos.xz - 0.905 * side * normalize(at_tangent).xz);
        }
    }

    // ---- Wall torches ----
    // Half-width from the face itself: older models are 16 px planes, newer
    // ones a 2 px box (plus 3 px redstone glow faces).
    else if (id == 10970) {
        if (gl_Normal.y > -0.1 || gl_Normal.y < -0.7) CULL
        vec2 axis = sign(abs(gl_Normal.zx));
        pos.xz = faceCamera(fwd.xz, side * dot(abs(mid.xz), axis), pos.xz + mid.xz * axis);
    }

    // Billy Boarding layers: 0.1% of the distance per rank along the view
    // ray, which changes depth but not screen position, so layers keep their
    // order from any angle.
    emitView((gl_ModelViewMatrix * pos).xyz * (1.0 - 0.001 * layer), uv);

    // The face's UV rectangle for texmap(): mc_midTexCoord is its center.
    vec2 h = abs(uv - mc_midTexCoord);
    uvRect = vec4(mc_midTexCoord - h, mc_midTexCoord + h);
}
