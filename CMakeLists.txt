cmake_minimum_required(VERSION 3.20)
project(swordfish-screensaver VERSION 0.2.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Prefer a distribution-provided SDL2. If unavailable (as on some EL10
# installations), fetch a pinned SDL2 release and build it as a static library.
find_package(SDL2 CONFIG QUIET)
if(TARGET SDL2::SDL2)
  set(SWORDFISH_SDL_TARGET SDL2::SDL2)
elseif(TARGET SDL2::SDL2-static)
  set(SWORDFISH_SDL_TARGET SDL2::SDL2-static)
else()
  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(SDL2 QUIET IMPORTED_TARGET sdl2)
  endif()

  if(TARGET PkgConfig::SDL2)
    set(SWORDFISH_SDL_TARGET PkgConfig::SDL2)
  else()
    include(FetchContent)
    set(SDL_SHARED OFF CACHE BOOL "" FORCE)
    set(SDL_STATIC ON CACHE BOOL "" FORCE)
    set(SDL_TEST OFF CACHE BOOL "" FORCE)
    set(SDL_TESTS OFF CACHE BOOL "" FORCE)
    set(SDL_TEST_LIBRARY OFF CACHE BOOL "" FORCE)
    set(SDL2_DISABLE_INSTALL ON CACHE BOOL "" FORCE)
    FetchContent_Declare(
      SDL2
      GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
      GIT_TAG release-2.30.11
      GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(SDL2)
    if(TARGET SDL2::SDL2-static)
      set(SWORDFISH_SDL_TARGET SDL2::SDL2-static)
    elseif(TARGET SDL2-static)
      set(SWORDFISH_SDL_TARGET SDL2-static)
    else()
      message(FATAL_ERROR "SDL2 was fetched but its static CMake target was not found")
    endif()
  endif()
endif()

find_package(OpenGL REQUIRED)
add_executable(swordfish-screensaver src/main.cpp)
target_link_libraries(swordfish-screensaver PRIVATE ${SWORDFISH_SDL_TARGET} OpenGL::GL)
if(WIN32)
  target_compile_definitions(swordfish-screensaver PRIVATE SDL_MAIN_HANDLED)
endif()
if(MSVC)
  target_compile_options(swordfish-screensaver PRIVATE /W4 /permissive-)
else()
  target_compile_options(swordfish-screensaver PRIVATE -Wall -Wextra -Wpedantic)
endif()

install(TARGETS swordfish-screensaver RUNTIME DESTINATION bin)

install(PROGRAMS scripts/swordfish-idle DESTINATION bin)
install(FILES packaging/swordfish-idle.desktop DESTINATION share/applications)
