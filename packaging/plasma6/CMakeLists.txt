cmake_minimum_required(VERSION 3.20)
project(swordfish-plasma6-wallpaper)

find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

find_package(KF6 REQUIRED COMPONENTS Plasma)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml)

plasma_install_package(package org.zwiegnet.swordfish wallpapers wallpaper)
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)


# Native Qt helper: QScreen supplies the real virtual desktop geometry and
# each wallpaper window's actual screen geometry.
find_package(Qt6 REQUIRED COMPONENTS Quick)

add_library(swordfishgeometryplugin MODULE
    geometry/DisplayGeometry.cpp
    geometry/DisplayGeometryPlugin.cpp
)
target_link_libraries(swordfishgeometryplugin PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)
set_target_properties(swordfishgeometryplugin PROPERTIES
    PREFIX ""
    OUTPUT_NAME "swordfishgeometryplugin"
)
set(SWORDFISH_GEOMETRY_DIR
    "${KDE_INSTALL_DATADIR}/plasma/wallpapers/org.zwiegnet.swordfish/contents/ui/org/zwiegnet/swordfish/geometry")
install(TARGETS swordfishgeometryplugin LIBRARY DESTINATION "${SWORDFISH_GEOMETRY_DIR}")
install(FILES geometry/qmldir DESTINATION "${SWORDFISH_GEOMETRY_DIR}")
