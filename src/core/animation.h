#pragma once
namespace swordfish {
struct AnimationFrame { double angle = 0.0; double direction = 1.0; int beamCount = 1; };
class AnimationEngine {
public:
    // Pure timeline evaluation: no SDL, OS, window, clock, or renderer dependency.
    static AnimationFrame evaluate(double elapsedSeconds) noexcept;
};
} // namespace swordfish
