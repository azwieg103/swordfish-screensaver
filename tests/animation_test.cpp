#include "core/animation.h"

#include <cmath>
#include <iostream>
#include <limits>
#include <string>

namespace {
bool check(bool condition, const std::string& message) {
    if (!condition) std::cerr << "FAIL: " << message << '\n';
    return condition;
}
}

int main() {
    using swordfish::AnimationEngine;
    bool ok = true;

    const auto start = AnimationEngine::evaluate(0.0);
    ok &= check(start.beamCount == 1, "starts with one beam");
    ok &= check(start.direction == 1.0, "starts clockwise");
    ok &= check(std::abs(start.angle) < 1e-9, "starts at zero angle");

    ok &= check(AnimationEngine::evaluate(9.0).beamCount == 2,
                "splits into two beams");
    ok &= check(AnimationEngine::evaluate(16.0).beamCount == 4,
                "splits into four beams");
    ok &= check(AnimationEngine::evaluate(28.0).beamCount == 1,
                "merges back into one beam");

    ok &= check(AnimationEngine::evaluate(24.999).direction == 1.0,
                "keeps direction before reversal");
    ok &= check(AnimationEngine::evaluate(25.0).direction == -1.0,
                "reverses after five revolutions");
    ok &= check(AnimationEngine::evaluate(50.0).direction == 1.0,
                "reverses back after ten revolutions");

    ok &= check(AnimationEngine::evaluate(-1.0).angle == 0.0,
                "clamps negative elapsed time");
    ok &= check(AnimationEngine::evaluate(
                    std::numeric_limits<double>::quiet_NaN()).angle == 0.0,
                "clamps NaN elapsed time");
    ok &= check(AnimationEngine::evaluate(
                    std::numeric_limits<double>::infinity()).angle == 0.0,
                "clamps infinite elapsed time");

    const auto veryLarge = AnimationEngine::evaluate(
        std::numeric_limits<double>::max());
    ok &= check(std::isfinite(veryLarge.angle),
                "handles very large finite elapsed time");

    return ok ? 0 : 1;
}
