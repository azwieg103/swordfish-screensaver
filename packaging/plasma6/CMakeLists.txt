cmake_minimum_required(VERSION 3.20)
project(swordfish-plasma6-wallpaper)

find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

find_package(Plasma REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick ShaderTools)

plasma_install_package(package org.zwiegnet.swordfish wallpapers wallpaper)

# Native helper provides virtual-desktop geometry and one process-wide
# monotonic animation clock shared by every per-monitor wallpaper instance.
add_library(swordfishgeometryplugin MODULE
    geometry/DisplayGeometry.cpp
    geometry/DisplayGeometryPlugin.cpp
)
target_link_libraries(swordfishgeometryplugin PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)
set_target_properties(swordfishgeometryplugin PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "swordfishgeometryplugin"
)

# Compile the fragment shader to Qt's portable QShader format at build time.
qt_add_shaders(swordfishgeometryplugin swordfish_shaders
    PREFIX "/org/zwiegnet/swordfish/shaders"
    FILES shaders/swordfish.frag
)

set(SWORDFISH_GEOMETRY_DIR
    "${KDE_INSTALL_QMLDIR}/org/zwiegnet/swordfish/geometry")
install(TARGETS swordfishgeometryplugin LIBRARY DESTINATION "${SWORDFISH_GEOMETRY_DIR}")
install(FILES geometry/qmldir DESTINATION "${SWORDFISH_GEOMETRY_DIR}")

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
