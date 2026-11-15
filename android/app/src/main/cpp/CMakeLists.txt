cmake_minimum_required(VERSION 3.22.1)
project(profile_native LANGUAGES C CXX ASM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

add_library(profile_native SHARED
        src/ffi_bridge.cpp
        src/xp_engine.cpp
        src/streak_engine.cpp
        src/stats_engine.cpp
        src/json_lite.cpp
        src/csv_engine.cpp
        src/image_fast.cpp
        src/translate_engine.cpp
        src/splash_engine.cpp
        src/tm_engine.cpp
        src/clip_filter.cpp
        src/mt_tk_engine.cpp
        src/crash_handler.cpp
        src/srs_engine.cpp
        src/bridge_engine.cpp
        src/kernels_text_engine.cpp
        src/kernels_pixel_engine.cpp
)

target_include_directories(profile_native PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_options(profile_native PRIVATE
        -fno-omit-frame-pointer
        -fno-fast-math
        -ffp-contract=off
        -Wall -Wextra
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(profile_native PRIVATE -O0 -g)
else()
    target_compile_options(profile_native PRIVATE -O3)
    target_compile_definitions(profile_native PRIVATE NDEBUG=1)
endif()

if(ANDROID_ABI STREQUAL "arm64-v8a")
    target_sources(profile_native PRIVATE src/asm/kernels_aarch64.S)
    target_compile_definitions(profile_native PRIVATE KP_HAS_ASM_KERNELS=1)
endif()

target_link_libraries(profile_native android log)