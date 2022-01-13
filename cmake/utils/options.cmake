# Copyright 2020 Autodesk, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ======================================
# NOTE: (Marcelo Sercheli) Use REZ env variables per package to identify which USD to use
if(DEFINED ENV{REZ_USD_ROOT})
    # USD-only and Maya environments use Pixar's USD and dependencies
    message(STATUS "Using USD from Pixar, including Boost and TBB from its depedencies.")

    set(REZ_BUILD_USE_CUSTOM_BOOST OFF)
    set(REZ_BUILD_SCHEMAS ON)

elseif(DEFINED ENV{REZ_HOUDINI_ROOT})
    # Houdini environment should use Houdini's USD, Boost and TBB
    message(STATUS "Using USD/Boost/TBB from Houdini")

    set(HOUDINI_LOCATION $ENV{HOUDINI_LOCATION})
    if($ENV{HOUDINI_MAJOR_RELEASE} EQUAL "18")
        set(HOUDINI_PYTHONPATH ${HOUDINI_LOCATION}/houdini/python2.7libs)
    elseif($ENV{HOUDINI_MAJOR_RELEASE} EQUAL "19")
        set(HOUDINI_PYTHONPATH ${HOUDINI_LOCATION}/houdini/python3.7libs)
    endif()

    # USD
    set(USD_LOCATION $ENV{HOUDINI_LOCATION})
    set(PXR_INCLUDE_DIRS ${USD_LOCATION}/toolkit/include)
    set(USD_PLUGINS_DIR ${USD_LOCATION}/dsolib/usd_plugins)
    if($ENV{HOUDINI_MAJOR_RELEASE} EQUAL "18")
        set(REZ_BUILD_SCHEMAS OFF)
        set(USD_PYTHONPATH ${USD_LOCATION}/python/lib/python2.7/site-packages)
    elseif($ENV{HOUDINI_MAJOR_RELEASE} EQUAL "19")
        set(REZ_BUILD_SCHEMAS ON)
        set(USD_PYTHONPATH ${USD_LOCATION}/python/lib/python3.7/site-packages)
    endif()
    set(USD_INCLUDE_DIR ${USD_LOCATION}/toolkit/include)
    set(USD_LIBRARY_DIR ${USD_LOCATION}/dsolib)
    set(USD_BINARY_DIR ${USD_LOCATION}/bin)
    set(USD_LIB_PREFIX libpxr_ CACHE STRING "Prefix of USD libraries")

    # Boost
    set(BOOST_LOCATION $ENV{HOUDINI_LOCATION})
    set(REZ_BUILD_USE_CUSTOM_BOOST ON)
    set(BOOST_ROOT ${BOOST_LOCATION})
    set(Boost_INCLUDE_DIRS ${BOOST_LOCATION}/toolkit/include/hboost)
    if($ENV{HOUDINI_MAJOR_RELEASE} EQUAL "18")
        set(Boost_LIBRARIES ${BOOST_LOCATION}/dsolib/libhboost_python27.so)
    elseif($ENV{HOUDINI_MAJOR_RELEASE} EQUAL "19")
        set(Boost_LIBRARIES ${BOOST_LOCATION}/dsolib/libhboost_python37.so)
    endif()

    # TBB
    set(TBB_FOUND ON)
    set(TBB_LOCATION $ENV{HOUDINI_LOCATION})
    set(TBB_ROOT_DIR ${TBB_LOCATION}/toolkit/include)
    set(TBB_INCLUDE_DIRS ${TBB_LOCATION}/toolkit/include)
    set(TBB_LIBRARIES ${TBB_LOCATION}/dsolib/libtbb.so)

else()
    message(FATAL_ERROR "Issue identifying which USD to look for.")
endif()

# ======================================

option(USD_MONOLITHIC_BUILD "Monolithic build was used for USD." OFF)
option(USD_STATIC_BUILD "USD is built as a static, monolithic library." OFF)
option(TBB_STATIC_BUILD "TBB is built as a static library." OFF)
option(TBB_NO_EXPLICIT_LINKAGE "Explicit linkage of TBB libraries is disabled on windows." OFF)
option(BUILD_USE_CUSTOM_BOOST "Using a custom boost layout." ${REZ_BUILD_USE_CUSTOM_BOOST})
option(BUILD_BOOST_ALL_NO_LIB "Disable linking of boost libraries from boost headers." OFF)
option(BUILD_DISABLE_CXX11_ABI "Disable the use of the new CXX11 ABI" ON)  # For USD 20.05 and later
option(BUILD_HEADERS_AS_SOURCES "Add headers are source files to the target to help when generating IDE projects." OFF)
set(USD_OVERRIDE_PLUGINPATH_NAME "PXR_PLUGINPATH_NAME" CACHE STRING "Override the plugin path name for the USD libraries. Used when running the testsuite with a static procedural")

option(BUILD_SCHEMAS "Builds the USD Schemas" ${REZ_BUILD_SCHEMAS})
option(BUILD_RENDER_DELEGATE "Builds the Render Delegate" ON)
option(BUILD_NDR_PLUGIN "Builds the NDR Plugin" ON)
option(BUILD_PROCEDURAL "Builds the Procedural" ON)
option(BUILD_PROC_SCENE_FORMAT "Enables the Procedural Scene format" ON)
option(BUILD_USD_WRITER "Builds the USD Writer" ON)
option(BUILD_USD_IMAGING_PLUGIN "Builds the USD Imaging plugins" ON)
option(BUILD_SCENE_DELEGATE "Builds the Scene Delegate" OFF)
option(BUILD_DOCS "Builds the Documentation" OFF)
option(BUILD_TESTSUITE "Builds the testsuite" OFF)
option(BUILD_UNIT_TESTS "Build the unit tests" OFF)
option(BUILD_USE_PYTHON3 "Use python 3." ON)

set(PREFIX_PROCEDURAL "procedural" CACHE STRING "Directory to install the procedural under.")
set(PREFIX_PLUGINS "plugin" CACHE STRING "Directory to install the plugins (Hydra and Ndr) under.")
set(PREFIX_HEADERS "include" CACHE STRING "Directory to install the headers under.")
set(PREFIX_SCHEMA "schema" CACHE STRING "Directory to install the schemas under.")
set(PREFIX_BIN "bin" CACHE STRING "Directory to install the binaries under.")
set(PREFIX_DOCS "docs" CACHE STRING "Directory to install the documentation under.")

set(TEST_DIFF_HARDFAIL "0.0157" CACHE STRING "Hard failure of an image comparison test.")
set(TEST_DIFF_FAIL "0.00001" CACHE STRING "Failure of an image comparison test.")
set(TEST_DIFF_FAILPERCENT "33.334" CACHE STRING "Failure percentage of an image comparison test.")
set(TEST_DIFF_WARNPERCENT "0.0" CACHE STRING "Warning percentage of an image comparison test.")
set(TEST_RESOLUTION "160 120" CACHE STRING "Resolution of unit tests.")
set(TEST_MAKE_THUMBNAILS "Enables the generation of test thumbnails." ON)

set(USD_PROCEDURAL_NAME "usd" CACHE STRING "Name of the usd procedural.")
