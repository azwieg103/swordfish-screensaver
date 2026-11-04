#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float phase;
    vec2 desktopSize;
    vec2 screenOrigin;
    vec2 screenSize;
    vec4 plasmaColor;
    float orbitSize;
    float beamWidth;
    float glow;
    float orbBrightness;
    float orbCount;
    float trailLength;
    float flameIntensity;
    float blankDuration;
    float speedScale;
    float shape;
    float direction;
};

const float PI = 3.14159265358979323846;

void main()
{
    vec2 p = screenOrigin + qt_TexCoord0 * screenSize;
    vec2 center = desktopSize * 0.5;
    float scale = max(0.1, orbitSize);
    float rx = desktopSize.x * 0.43 * scale;
    float ry = desktopSize.y * 0.36 * scale;

    if (shape > 0.5 && shape < 1.5) {
        rx = min(desktopSize.x, desktopSize.y) * 0.40 * scale;
        ry = rx;
    } else if (shape > 1.5 && shape < 2.5) {
        rx = desktopSize.x * 0.60 * scale;
        ry *= 0.62;
    } else if (shape > 2.5) {
        rx *= 0.62;
    }

    vec3 color = vec3(0.003, 0.006, 0.014);

    // One full revolution, a smooth fade-out, an adjustable blackout,
    // then a smooth fade-in before the next revolution.
    float travelUnits = 90.0 / max(1.0, speedScale * 20.0);
    const float fadeUnits = 1.25;
    float blankUnits = max(0.0, blankDuration);
    float cycleUnits = travelUnits + fadeUnits * 2.0 + blankUnits;
    float cycleNumber = floor(phase / cycleUnits);
    float cyclePhase = mod(phase, cycleUnits);
    float animationAlpha = 1.0;
    float motionPhase = 0.0;
    float orbitCycle = cycleNumber;

    // Keep moving during the fade-out. The completed lap therefore does not
    // freeze at a monitor edge or reset to the same position after blackout.
    if (cyclePhase < travelUnits) {
        motionPhase = cyclePhase / travelUnits;
    } else if (cyclePhase < travelUnits + fadeUnits) {
        motionPhase = 1.0 + (cyclePhase - travelUnits) / travelUnits;
        animationAlpha = 1.0 - smoothstep(0.0, fadeUnits,
                                          cyclePhase - travelUnits);
    } else if (cyclePhase < travelUnits + fadeUnits + blankUnits) {
        fragColor = vec4(color, 1.0) * qt_Opacity;
        return;
    } else {
        // Fade back in at the next orbit's randomly selected point. Use the
        // next cycle's seed here so the position and direction match exactly
        // when the following visible revolution begins.
        orbitCycle = cycleNumber + 1.0;
        motionPhase = 0.0;
        animationAlpha = smoothstep(0.0, fadeUnits,
            cyclePhase - travelUnits - fadeUnits - blankUnits);
    }

    // All monitor instances derive identical direction and starting position
    // from the shared monotonic clock and the same orbit-cycle number.
    float directionSeed = fract(sin(orbitCycle * 127.1 + 311.7) * 43758.5453);
    float randomDirection = directionSeed < 0.5 ? -1.0 : 1.0;
    float motionDirection = direction == 0.0 ? randomDirection : direction;
    float randomStart = fract(sin(orbitCycle * 269.5 + 183.3) * 24634.6345);
    float angleBase = motionDirection * (randomStart + motionPhase) * (2.0 * PI);
    vec3 effectTint = plasmaColor.rgb * animationAlpha;

    vec2 q = p - center;
    float normalizedRadius = length(vec2(q.x / max(rx, 1.0), q.y / max(ry, 1.0)));
    float orbitDistance = abs(normalizedRadius - 1.0) * min(rx, ry);
    float lineWidth = 0.7 + beamWidth * 0.10;
    float line = 1.0 - smoothstep(lineWidth, lineWidth + 1.5, orbitDistance);
    color += effectTint * line * (0.20 + glow * 0.16);

    float count = clamp(floor(orbCount + 0.5), 1.0, 8.0);
    float headRadius = 8.0 + beamWidth * 0.35;
    float pixelAngle = atan(q.y / max(ry, 1.0), q.x / max(rx, 1.0));

    // Trail length is an arc along the orbit, keeping the comet plume
    // attached to the path on both oval and circle shapes.
    float trailAngle = mix(0.08, 1.35, clamp(trailLength / 100.0, 0.0, 1.0));
    float trailWidth = max(1.5, lineWidth * (1.8 + glow * 1.4));
    float trailCoreWidth = max(1.0, trailWidth * 0.38);
    float trailHalo = exp(-pow(orbitDistance / trailWidth, 2.0));
    float trailCore = exp(-pow(orbitDistance / trailCoreWidth, 2.0));

    for (int i = 0; i < 8; ++i) {
        if (float(i) >= count)
            break;

        float angle = angleBase + float(i) * (2.0 * PI / count);
        vec2 head = center + vec2(rx * cos(angle), ry * sin(angle));
        vec2 rel = p - head;
        float d = length(rel);

        // A soft, animated meteor flame streams behind the round orb.
        // The flame follows the ellipse tangent, so it stays behind the
        // orb regardless of orbit shape or travel direction.
        vec2 tangent = normalize(vec2(-rx * sin(angle), ry * cos(angle)) * motionDirection);
        vec2 normal = vec2(-tangent.y, tangent.x);
        float flameBack = -dot(rel, tangent);
        float flameSide = dot(rel, normal);
        float flameLength = headRadius * (5.0 + trailLength * 0.10);
        float flameU = flameBack / max(1.0, flameLength);
        float flicker = sin(flameU * 25.0 - phase * 8.0 + float(i) * 2.1) * 0.22
                      + sin(flameU * 43.0 + phase * 5.7 + float(i)) * 0.12;
        float flameWidth = headRadius * (0.78 + 0.25 * sin(flameU * PI))
                         * (1.0 - 0.66 * clamp(flameU, 0.0, 1.0));
        float flameCenter = flicker * headRadius * (0.65 + flameU * 0.45);
        float flameEdge = abs(flameSide - flameCenter);
        float flameShape = 1.0 - smoothstep(flameWidth * 0.48,
                                            max(1.0, flameWidth), flameEdge);
        float flameFade = (1.0 - smoothstep(0.72, 1.0, flameU))
                        * smoothstep(-0.08, 0.08, flameU);
        float flame = flameShape * flameFade;
        vec3 flameColor = mix(effectTint, vec3(1.0, 0.78, 0.38), 0.48);
        vec3 flameCoreColor = mix(effectTint, vec3(1.0), 0.72);
        float flamePower = clamp(flameIntensity / 100.0, 0.0, 2.0);
        color += flameColor * flame * (0.75 + glow * 0.65)
                 * orbBrightness * flamePower;
        float hotCore = flame * (1.0 - smoothstep(0.0, flameWidth * 0.42, flameEdge));
        color += flameCoreColor * hotCore * 0.75 * orbBrightness * flamePower;

        float behindAngle = mod((angle - pixelAngle) * motionDirection + 2.0 * PI,
                                2.0 * PI);
        float trailProgress = behindAngle / trailAngle;
        float trailActive = 1.0 - smoothstep(0.94, 1.0, trailProgress);
        float tailFade = pow(max(0.0, 1.0 - trailProgress), 0.72);
        float trailMask = trailActive * tailFade;

        color += effectTint * trailHalo * trailMask
                 * (0.55 + glow * 0.85) * orbBrightness;
        color += effectTint * trailCore * trailMask
                 * (0.65) * orbBrightness;

        // Radial falloff keeps every orb round and smoothly glowing.
        float halo = exp(-pow(d / max(1.0, headRadius * (2.0 + glow * 1.8)), 2.0));
        float core = exp(-d * d / max(1.0, headRadius * headRadius * 0.48));
        color += effectTint * halo * (0.45 + glow * 0.75)
                 * orbBrightness;
        color += effectTint * core * 1.35 * orbBrightness;
    }

    fragColor = vec4(color, 1.0) * qt_Opacity;
}
