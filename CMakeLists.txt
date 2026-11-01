cmake_minimum_required(VERSION 3.20)
project(CoA_Localizer CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. 自动拉取 MinHook
include(FetchContent)
FetchContent_Declare(
    minhook
    GIT_REPOSITORY https://github.com/TsudaKageyu/minhook.git
    GIT_TAG master
)
FetchContent_MakeAvailable(minhook)

# 2. 自动下载单头文件 nlohmann/json.hpp
set(JSON_HPP_PATH "${CMAKE_BINARY_DIR}/include/json.hpp")
if(NOT EXISTS "${JSON_HPP_PATH}")
    message(STATUS "Downloading nlohmann/json.hpp...")
    file(DOWNLOAD
        "https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp"
        "${JSON_HPP_PATH}"
        SHOW_PROGRESS
    )
endif()

# 3. 编译生成 version.dll
add_library(version SHARED
    src/dllmain.cpp
    src/version.def
)

# 强制 MSVC 使用 UTF-8 编码解析源码中的中文字符串
target_compile_options(version PRIVATE "$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

target_include_directories(version PRIVATE
    ${minhook_SOURCE_DIR}/include
    "${CMAKE_BINARY_DIR}/include"
    src
)

target_link_libraries(version PRIVATE minhook winhttp)