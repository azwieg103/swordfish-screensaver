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
