project(arnold-usd)

cmake_minimum_required(VERSION 3.20)

if (UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif ()

if (LINUX)
    set(LIB_EXTENSION ".so")
    add_compile_definitions(_LINUX)
elseif (APPLE)
    set(LIB_EXTENSION ".dylib")
    add_compile_definitions(_DARWIN)
else ()
    set(LIB_EXTENSION ".dll")
    add_compile_definitions(_WINDOWS _WIN32 WIN32)
    add_compile_definitions(_WIN64)
endif ()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules" 0)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/utils" 0)

include(options)
include(build)

# Global required packagse
find_package(USD REQUIRED)
find_package(Arnold REQUIRED)

if (BUILD_SCHEMAS OR (BUILD_TESTSUITE AND BUILD_RENDER_DELEGATE AND BUILD_NDR_PLUGIN))
    if (BUILD_USE_PYTHON3)
        find_package(Python3 COMPONENTS Development Interpreter REQUIRED)
    else ()
        find_package(Python2 COMPONENTS Development Interpreter REQUIRED)
    endif ()
else ()
    if (BUILD_USE_PYTHON3)
        find_package(Python3 COMPONENTS Development REQUIRED)
    else ()
        find_package(Python2 COMPONENTS Development REQUIRED)
    endif ()
endif ()

if (BUILD_USE_PYTHON3)
    set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
else ()
    set(PYTHON_EXECUTABLE ${Python2_EXECUTABLE})
endif ()

if (NOT BUILD_USE_CUSTOM_BOOST)
    if (USD_HAS_PYTHON)

        #find_package(Boost COMPONENTS python REQUIRED)

        # ==========================================
        # NOTE: (Marcelo Sercheli): From USD to find Boost

        if (BUILD_USE_PYTHON3)
            set(PYTHON_VERSION_MAJOR ${Python3_VERSION_MAJOR})
            set(PYTHON_VERSION_MINOR ${Python3_VERSION_MINOR})
        else ()
            set(PYTHON_VERSION_MAJOR ${Python2_VERSION_MAJOR})
            set(PYTHON_VERSION_MINOR ${Python2_VERSION_MINOR})
        endif ()

        # Set up a version string for comparisons. This is available
        # as Boost_VERSION_STRING in CMake 3.14+
        # Find Boost package before getting any boost specific components as we need to
        # disable boost-provided cmake config, based on the boost version found.
        find_package(Boost REQUIRED)
        set(boost_version_string "${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}")

        # Boost provided cmake files (introduced in boost version 1.70) result in
        # inconsistent build failures on different platforms, when trying to find boost
        # component dependencies like python, program options, etc. Refer some related
        # discussions:
        # https://github.com/boostorg/python/issues/262#issuecomment-483069294
        # https://github.com/boostorg/boost_install/issues/12#issuecomment-508683006
        #
        # Hence to avoid issues with Boost provided cmake config, Boost_NO_BOOST_CMAKE
        # is enabled by default for boost version 1.70 and above. If a user explicitly
        # set Boost_NO_BOOST_CMAKE to Off, following will be a no-op.
        if (${boost_version_string} VERSION_GREATER_EQUAL "1.70")
            option(Boost_NO_BOOST_CMAKE "Disable boost-provided cmake config" ON)
            if (Boost_NO_BOOST_CMAKE)
                message(STATUS "Disabling boost-provided cmake config")
            endif()
        endif()

        find_package(Boost COMPONENTS program_options REQUIRED)
        if (${boost_version_string} VERSION_GREATER_EQUAL "1.67")
            # As of boost 1.67 the boost_python component name includes the
            # associated Python version (e.g. python27, python36).
            # XXX: After boost 1.73, boost provided config files should be able to
            # work without specifying a python version!
            # https://github.com/boostorg/boost_install/blob/master/BoostConfig.cmake

            # Find the component under the versioned name and then set the generic
            # Boost_PYTHON_LIBRARY variable so that we don't have to duplicate this
            # logic in each library's CMakeLists.txt.
            set(python_version_nodot "${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}")
            find_package(Boost COMPONENTS python${python_version_nodot} REQUIRED)
            set(Boost_PYTHON_LIBRARY "${Boost_PYTHON${python_version_nodot}_LIBRARY}")
        else()
            find_package(Boost COMPONENTS python REQUIRED)
        endif()
        # ==========================================

    else ()
        find_package(Boost REQUIRED)
    endif ()
endif ()
# This disables explicit linking from boost headers on Windows.
if (BUILD_BOOST_ALL_NO_LIB AND WIN32)
    add_compile_definitions(BOOST_ALL_NO_LIB=1)
    # This is for Houdini's boost libs.
    add_compile_definitions(HBOOST_ALL_NO_LIB=1)
endif ()

find_package(TBB REQUIRED)

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/arnold_usd.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/arnold_usd.h")

set(CMAKE_CXX_STANDARD 14 CACHE STRING "CMake CXX Standard")  # For USD 20.05 and later

if (APPLE)
    string(APPEND CMAKE_SHARED_LINKER_FLAGS " -Wl,-undefined,error")
elseif (LINUX)
    string(APPEND CMAKE_SHARED_LINKER_FLAGS " -Wl,--no-undefined")
endif ()

if (WIN32)
    # So we can use std::min and std::max, because windows headers are indirectly included by TF.
    add_compile_definitions(NOMINMAX)
    if (TBB_NO_EXPLICIT_LINKAGE)
        add_compile_definitions(__TBB_NO_IMPLICIT_LINKAGE=1)
    endif ()
endif ()

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 6.3)
        # GCC 6.3.1 complains about the usage of auto_ptr from the newer
        # TBB versions.
        add_compile_options(-Wno-deprecated-declarations)
        if (BUILD_DISABLE_CXX11_ABI)
            add_compile_options(-D_GLIBCXX_USE_CXX11_ABI=0)
        endif ()
    endif ()
endif ()

# Common directory includes.
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/common")
set(COMMON_SRC
    "${CMAKE_CURRENT_SOURCE_DIR}/common/common_utils.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/common/constant_strings.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/common/shape_utils.cpp")

set(COMMON_HDR
    "${CMAKE_CURRENT_SOURCE_DIR}/common/common_bits.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/common/common_utils.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/common/constant_strings.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/common/shape_utils.h")

if (BUILD_SCHEMAS AND USD_HAS_PYTHON)
    add_subdirectory(schemas)
    install(FILES plugInfo.json
        DESTINATION "${PREFIX_SCHEMA}")
endif ()

if (NOT USD_STATIC_BUILD)
    if (BUILD_NDR_PLUGIN)
        add_subdirectory(ndr)
    endif ()

    if (BUILD_RENDER_DELEGATE)
        add_subdirectory(render_delegate)
    endif ()

    if (BUILD_USD_IMAGING_PLUGIN)
        add_subdirectory(usd_imaging)
    endif ()

    if (BUILD_SCENE_DELEGATE)
        add_subdirectory(scene_delegate)
    endif ()

    if (BUILD_RENDER_DELEGATE OR BUILD_NDR_PLUGIN OR BUILD_USD_IMAGING_PLUGIN OR BUILD_SCENE_DELEGATE)
        install(FILES plugInfo.json
            DESTINATION "${PREFIX_PLUGINS}")
    endif ()
endif ()

if (BUILD_PROCEDURAL OR BUILD_USD_WRITER)
    add_subdirectory(translator)
endif ()

if (BUILD_PROCEDURAL)
    add_subdirectory(procedural)
endif ()

if (BUILD_USD_WRITER)
    add_subdirectory(cmd)
endif ()

if (BUILD_DOCS)
    add_subdirectory(docs)
endif ()

if (BUILD_TESTSUITE)
    enable_testing()
    add_subdirectory(testsuite)
endif ()

install(FILES LICENSE.md
    DESTINATION .)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/arnold_usd.h"
    DESTINATION "${PREFIX_HEADERS}/arnold_usd")
