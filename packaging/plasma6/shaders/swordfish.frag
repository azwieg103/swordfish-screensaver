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
        // Wider oval: extend the horizontal radius so it spans more of
        // the virtual desktop instead of appearing compressed in the center.
        rx = desktopSize.x * 0.60 * scale;
        ry *= 0.62;
    } else if (shape > 2.5) {
        rx *= 0.62;
    }

    vec2 q = p - center;
    float normalizedRadius = length(vec2(q.x / max(rx, 1.0), q.y / max(ry, 1.0)));
    float orbitDistance = abs(normalizedRadius - 1.0) * min(rx, ry);
    float lineWidth = 0.7 + beamWidth * 0.10;
    float line = 1.0 - smoothstep(lineWidth, lineWidth + 1.5, orbitDistance);

    vec3 color = vec3(0.003, 0.006, 0.014);
    color += plasmaColor.rgb * line * (0.20 + glow * 0.16);

    float count = clamp(floor(orbCount + 0.5), 1.0, 8.0);
    const float pulseUnits = 4.0;
    // pulseInterval is expressed in the shader's speed-scaled time units.
    // Two equal travel legs are followed by a short radiating pulse.
    float travelUnits = max(10.0, pulseInterval);
    float legUnits = travelUnits * 0.5;
    float cycleUnits = travelUnits + pulseUnits;
    float cyclePhase = mod(phase, cycleUnits);
    bool pulseStage = cyclePhase >= travelUnits;
    float legPhase = mod(cyclePhase, legUnits);
    float legIndex = cyclePhase < legUnits ? 0.0 : 1.0;
    float motionDirection = direction == 0.0
                            ? (legIndex < 0.5 ? 1.0 : -1.0)
                            : direction;
    float angleBase = motionDirection * (legPhase / legUnits) * (4.0 * 2.0 * PI);
    float pulsePhase = max(0.0, cyclePhase - travelUnits);
    float pulse = pulseStage
                  ? exp(-pow((pulsePhase - 1.15) / 0.48, 2.0))
                  : 0.0;
    float pulseBoost = 1.0 + pulse * 3.2;
    float headRadius = 8.0 + beamWidth * 0.35 + pulse * 12.0;
    float pixelAngle = atan(q.y / max(ry, 1.0), q.x / max(rx, 1.0));

    // Trail length is an arc along the orbit, not a straight tangent.
    // This keeps the comet plume attached to the orbit on both oval and circle shapes.
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
        float d = length(p - head);

        // Positive angular distance behind the moving head, following the ellipse.
        float behindAngle = mod((angle - pixelAngle) * motionDirection + 2.0 * PI,
                                2.0 * PI);
        float trailProgress = behindAngle / trailAngle;
        float trailActive = 1.0 - smoothstep(0.94, 1.0, trailProgress);
        float tailFade = pow(max(0.0, 1.0 - trailProgress), 0.72);
        float trailMask = trailActive * tailFade;

        color += plasmaColor.rgb * trailHalo * trailMask
                 * (0.55 + glow * 0.85) * pulseBoost * orbBrightness;
        color += plasmaColor.rgb * trailCore * trailMask
                 * (0.65 + pulse * 0.8) * orbBrightness;

        // Radial falloff keeps every orb round; its color follows the selected palette.
        float halo = exp(-pow(d / max(1.0, headRadius * (2.0 + glow * 1.8)), 2.0));
        float core = exp(-d * d / max(1.0, headRadius * headRadius * 0.48));
        color += plasmaColor.rgb * halo * (0.45 + glow * 0.75)
                 * pulseBoost * orbBrightness;
        color += plasmaColor.rgb * core * (1.35 + pulse * 1.4) * orbBrightness;
    }

    fragColor = vec4(color, 1.0) * qt_Opacity;
}
