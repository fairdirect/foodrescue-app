# ################# Lists to maintain manually #####################################################

# Directories where Qt Creator can find QML files of Kirigami etc. on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
#   (Source: https://stackoverflow.com/a/38266179)
list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml")


# ################# CMake boilerplate ##############################################################

cmake_minimum_required(VERSION 3.0)
project(foodrescue-app VERSION ${KF5_VERSION})

# Do not allow in-source builds.
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "foodrescue-app requires an out of source build. Please create a separate build directory and run 'cmake path_to_kirigami [options]' there.")
endif()


# ################# CMake module includes ##########################################################

# include()s have to be up here because the new CMake functionality can only be used afterwards.

include(FeatureSummary)

# CPack available to easily generate binary packages.
include(CPack)

# Include KDE-related CMake modules (ECM = Extended CMake Modules).
find_package(ECM 5.47.0 REQUIRED NO_MODULE)
set_package_properties(
    ECM PROPERTIES
    TYPE REQUIRED
    DESCRIPTION "Extra CMake Modules."
    URL "https://projects.kde.org/projects/kdesupport/extra-cmake-modules"
)
# Where to look for modules before ${CMAKE_ROOT}/Modules/.
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})
# Include specific ECM modules.
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(ECMQMLModules)


# ################# Misc configuration #############################################################

# TODO: What's this?
feature_summary(
    WHAT ALL
    INCLUDE_QUIET_PACKAGES
    FATAL_ON_MISSING_REQUIRED_PACKAGES
)

# TODO: What's this?
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# TODO: What's this? It's not in the Kirigami repo's app template, so maybe not needed.
set(CMAKE_AUTOMOC ON)
set(AUTOMOC_MOC_OPTIONS -Muri=org.kde.kirigami)

# TODO: What's this?
add_definitions(-DQT_NO_URL_CAST_FROM_STRING)

# Enable C++11 features for clang and gcc.
set(CMAKE_CXX_STANDARD 11)

# Tell Qt Creator where to find QML files to make code completion happy.
set(
    QML_IMPORT_PATH "${QML_DIRS}"
    CACHE STRING "Qt Creator 4.1 extra qml import paths"
)


# ################# Application dependencies (packages, QML modules) ###############################

# Find the Qt installation.
# Application depends on the Qt required by the Kirigami version found in Ubuntu 20.04 LTS.
# Which is 5.12.0. See README.md for the reasoning and source.
set(REQUIRED_QT_VERSION 5.12.0)
find_package(
    Qt5 ${REQUIRED_QT_VERSION}
    REQUIRED
    NO_MODULE
    COMPONENTS Core Qml Gui Svg QuickControls2
    # TODO: If the above causes issues, replace with previous version:
    # COMPONENTS Core Quick Gui Svg QuickControls2
)
if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(Qt5AndroidExtras ${REQUIRED_QT_VERSION} REQUIRED)
endif()

# Find Kirigami and other relevant KDE components.
find_package(KF5Kirigami2 REQUIRED)
find_package(KF5I18n) # TODO: Remove in case KDE i18n is not being used.

# Include specific QML modules. (Example; enable when needed.)
# ecm_find_qmlmodule(QtGraphicalEffects 1.0)


# ################# Compilation and installation ###################################################

# Build and install the executable from the source tree, as instructed in src/CMakeLists.txt.
add_subdirectory(src)

# Install the FreeDesktop application metadata file.
install(
    FILES metadata-freedesktop.desktop
    DESTINATION ${KDE_INSTALL_APPDIR}
    RENAME org.fairdirect.foodrescue.desktop
)

# Install the KDE AppStream application metadata file.
install(
    FILES metadata-kde.xml
    DESTINATION ${KDE_INSTALL_METAINFODIR}
    RENAME org.fairdirect.foodrescue.appdata.xml
)

# TODO: What's this for? Something from KDE i18n?
if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/po")
    ecm_install_po_files_as_qm(po)
endif()
