cmake_minimum_required(VERSION 3.16)
project(QtNSWindowSheetIntegration)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置Objective-C++编译选项
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD_REQUIRED ON)

# 查找Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

# 查找Cocoa框架
find_library(COCOA_FRAMEWORK Cocoa)

# 包含目录
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# 源文件
set(SOURCES
    QtSheetContainer.mm
    QtSheetManager.mm
    QtSheetIntegration.mm
    QtSheetWidget.cpp
    ExampleUsage.mm
)

# 头文件
set(HEADERS
    QtSheetContainer.h
    QtSheetManager.h
    QtSheetIntegration.h
    QtSheetWidget.h
)

# 创建可执行文件
add_executable(QtNSWindowSheetIntegration ${SOURCES} ${HEADERS})

# 链接Qt库
target_link_libraries(QtNSWindowSheetIntegration
    Qt6::Core
    Qt6::Widgets
    ${COCOA_FRAMEWORK}
)

# 设置Qt的MOC处理
set_target_properties(QtNSWindowSheetIntegration PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    AUTOUIC ON
)

# macOS特定设置
if(APPLE)
    set_target_properties(QtNSWindowSheetIntegration PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "Qt NSWindow Sheet Integration"
        MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    )
    
    # 设置Info.plist
    set_target_properties(QtNSWindowSheetIntegration PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    )
endif()

# 编译选项
target_compile_options(QtNSWindowSheetIntegration PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)

# 调试信息
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(QtNSWindowSheetIntegration PRIVATE -g -O0)
else()
    target_compile_options(QtNSWindowSheetIntegration PRIVATE -O2)
endif()