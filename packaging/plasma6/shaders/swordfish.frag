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

    for (int i = 0; i < 8; ++i) {
        if (float(i) >= count)
            break;
        float angle = angleBase + float(i) * (2.0 * PI / count);
        vec2 head = center + vec2(rx * cos(angle), ry * sin(angle));
        float d = length(p - head);
        float halo = exp(-d / max(1.0, headRadius * (2.0 + glow * 1.8)));
        float core = exp(-d * d / max(1.0, headRadius * headRadius * 0.55));
        color += plasmaColor.rgb * halo * (0.45 + glow * 0.75);
        color += vec3(0.75, 0.95, 1.0) * core * 0.85;
    }

    fragColor = vec4(color, 1.0) * qt_Opacity;
}
