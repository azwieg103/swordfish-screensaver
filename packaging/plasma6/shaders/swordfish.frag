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
    float orbCount;
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
        ry *= 0.62;
    } else if (shape > 2.5) {
        rx *= 0.62;
    }

    vec2 q = p - center;
    float normalizedRadius = length(vec2(q.x / max(rx, 1.0), q.y / max(ry, 1.0)));
    float orbitDistance = abs(normalizedRadius - 1.0) * min(rx, ry);
    float lineWidth = 0.7 + beamWidth * 0.10;
    float line = 1.0 - smoothstep(lineWidth, lineWidth + 1.5, orbitDistance);

    vec3 base = vec3(0.003, 0.006, 0.014);
    vec3 color = base + plasmaColor.rgb * line * (0.20 + glow * 0.16);

    float count = clamp(floor(orbCount + 0.5), 1.0, 8.0);
    float angleBase = direction * phase * (2.0 * PI / 18.0);
    float headRadius = 3.0 + beamWidth * 0.22;
    float pixelAngle = atan(q.y / max(ry, 1.0), q.x / max(rx, 1.0));
    const float tailLength = 0.58;

    for (int i = 0; i < 8; ++i) {
        if (float(i) >= count)
            break;

        float angle = angleBase + float(i) * (2.0 * PI / count);
        vec2 head = center + vec2(rx * cos(angle), ry * sin(angle));
        float d = length(p - head);

        // Each comet flashes briefly at staggered intervals, followed by a
        // softer afterglow. The shared phase keeps all monitor instances aligned.
        float pulseCycle = mod(phase + float(i) * 6.1, 18.0);
        float flash = exp(-pow((pulseCycle - 0.65) / 0.22, 2.0));
        float afterglow = exp(-max(0.0, pulseCycle - 0.65) * 2.0)
                          * (1.0 - smoothstep(0.65, 1.2, pulseCycle));
        float pulse = clamp(flash + afterglow * 0.35, 0.0, 1.0);
        float pulseBoost = 1.0 + pulse * 1.8;

        // A tapered arc follows the orbit behind each moving head.
        // The thin base orbit remains visible underneath the comet tail.
        float trailAngle = mod(direction * (angle - pixelAngle) + 2.0 * PI,
                               2.0 * PI);
        float trailProgress = clamp(trailAngle / tailLength, 0.0, 1.0);
        float trailFade = pow(max(0.0, 1.0 - trailProgress), 1.45);
        float trailActive = 1.0 - smoothstep(tailLength * 0.88,
                                             tailLength, trailAngle);
        float taper = mix(0.12, 1.0, exp(-trailProgress * 2.0));
        float tailCoreWidth = (1.0 + beamWidth * 0.075) * taper;
        float tailGlowWidth = (headRadius * (1.7 + glow * 1.8)) * taper;
        float tailCore = exp(-pow(orbitDistance / max(0.8, tailCoreWidth), 2.0));
        float tailGlow = exp(-orbitDistance / max(1.0, tailGlowWidth * 2.5));

        color += plasmaColor.rgb * tailGlow * trailFade * trailActive
                 * (0.75 + glow * 0.9) * pulseBoost;
        color += mix(plasmaColor.rgb, vec3(0.72, 0.96, 1.0), 0.28)
                 * tailCore * trailFade * trailActive * (1.25 + pulse * 1.9);

        float halo = exp(-d / max(1.0, headRadius * (2.0 + glow * 1.8)));
        float core = exp(-d * d / max(1.0, headRadius * headRadius * 0.55));
        color += plasmaColor.rgb * halo * (0.45 + glow * 0.75) * pulseBoost;
        color += vec3(0.75, 0.95, 1.0) * core * (0.85 + pulse * 1.8);
    }

    fragColor = vec4(color, 1.0) * qt_Opacity;
}
