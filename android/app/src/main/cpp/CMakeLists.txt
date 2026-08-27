cmake_minimum_required(VERSION 3.22.1)
project("profile_native")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_language(ASM)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

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
)

if(CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    target_compile_definitions(profile_native PRIVATE NDEBUG=1)
    target_compile_options(profile_native PRIVATE -O3 -ffast-math -fomit-frame-pointer)
else()
    target_compile_options(profile_native PRIVATE -O0 -g)
endif()

if(ANDROID_ABI STREQUAL "arm64-v8a")
    target_sources(profile_native PRIVATE src/asm/kernels_aarch64.S)
    target_compile_definitions(profile_native PRIVATE KP_HAS_ASM_KERNELS=1)
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
    target_sources(profile_native PRIVATE src/asm/kernels_armv7.S)
    target_compile_definitions(profile_native PRIVATE KP_HAS_ASM_KERNELS=1)
    target_compile_options(profile_native PRIVATE -mfpu=neon -mfloat-abi=softfp)
endif()

target_link_libraries(profile_native android log)