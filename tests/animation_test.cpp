#include "core/animation.h"
#include <cassert>
#include <cmath>
int main() {
    using swordfish::AnimationEngine;
    const auto start = AnimationEngine::evaluate(0.0);
    assert(start.beamCount == 1 && start.direction == 1.0 && std::abs(start.angle) < 1e-9);
    assert(AnimationEngine::evaluate(9.0).beamCount == 2);
    assert(AnimationEngine::evaluate(16.0).beamCount == 4);
    assert(AnimationEngine::evaluate(28.0).beamCount == 1);
    assert(AnimationEngine::evaluate(25.0).direction == -1.0);
    assert(AnimationEngine::evaluate(-1.0).angle == 0.0);
    assert(AnimationEngine::evaluate(NAN).angle == 0.0);
    return 0;
}
