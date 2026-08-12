cmake_minimum_required(VERSION 3.22.1)
project("profile_native")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
)

target_compile_options(profile_native PRIVATE -O3 -ffast-math)
target_link_libraries(profile_native android log)