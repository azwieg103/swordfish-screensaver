#include "animation.h"
#include <cmath>

namespace swordfish {
namespace {
constexpr double kPi = 3.14159265358979323846;
constexpr double kTau = 2.0 * kPi;
}

AnimationFrame AnimationEngine::evaluate(double elapsedSeconds) noexcept {
    if (!std::isfinite(elapsedSeconds) || elapsedSeconds < 0.0) {
        elapsedSeconds = 0.0;
    }

    // One revolution takes five seconds. Reverse direction after every five
    // revolutions (25 seconds), without converting unbounded elapsed time to
    // an integer type.
    const double reversalPhase = std::fmod(elapsedSeconds / 25.0, 2.0);
    const double direction = reversalPhase < 1.0 ? 1.0 : -1.0;
    const double withinLeg = std::fmod(elapsedSeconds, 25.0) / 5.0;
    const double angle = direction > 0.0
        ? withinLeg * kTau
        : (5.0 - withinLeg) * kTau;

    double cycle = std::fmod(elapsedSeconds, 32.0);
    if (cycle < 0.0) cycle += 32.0;
    const double splitWave = (cycle < 8.0 || cycle >= 24.0) ? 0.0 :
        (cycle < 12.0 ? (cycle - 8.0) / 4.0 :
         cycle < 20.0 ? 1.0 : (24.0 - cycle) / 4.0);
    const int beamCount = splitWave < 0.34 ? 1 :
                          splitWave < 0.84 ? 2 : 4;
    return {angle, direction, beamCount};
}
} // namespace swordfish
