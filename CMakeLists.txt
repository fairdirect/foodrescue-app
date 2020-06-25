# ################# CMake boilerplate ##############################################################

# Do not allow in-source builds.
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "This application requires an out-of-source build. Please create a separate build directory and run 'cmake path_to_kirigami [options]' there.")
endif()


# ################# Project configuration #############################################################

# Require CMake ≥3.3 to get the IN_LIST operator.
#   Required up here, before any usage of the affected language features.
cmake_minimum_required(VERSION 3.0)

# Project name and version. Also enables "CXX" language
project(foodrescue-app VERSION 0.1)

# TODO: What's this?
include(FeatureSummary)
feature_summary(
    WHAT ALL
    INCLUDE_QUIET_PACKAGES
    FATAL_ON_MISSING_REQUIRED_PACKAGES
)

# Set the minimum required Qt version.
#   Application depends on the Qt required by "the Kirigami found in Ubuntu 20.04 LTS", which is
#   5.12.0. Supplying a higher version is fine; Ubuntu 20.04 LTS comes with Qt 5.12.5 for example.
#
#   See README.md for the reasoning and source.
set(REQUIRED_QT_VERSION 5.12.0)

# Application depends on KDE Framework version found in Ubuntu 20.04 LTS.
#   See README.md for the reasoning and source.
set(KF5_DEP_VERSION 5.68.0)

# If building for Android and Breeze icons are installed under ./lib/breeze-icons/, set the path.
#   If not installed, the build process will do a git clone to "breeze-icons" in the build
#   directory.
#
#   For documentation of the technique here and instructions to make a local change for your
#   system only, see https://stackoverflow.com/a/62202304
#
#   TODO: Later we want to use the breeze icons provided by the Ubuntu package under
#   /usr/share/icons/breeze. However, the folder structure there is different than what
#   _find_breeze_icon() expects. Once that is fixed, the code below should first look for the
#   Ubuntu package and only afterwards for ./lib/breeze-icons. For the code to fix, see:
#   https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/KF5Kirigami2Macros.cmake#L17
get_filename_component(
    PROJECT_BREEZEICONS_DIR # Target variable to set.
    "lib/breeze-icons"      # Path relative to the project's source (!!) directory.
    REALPATH                # Convert to an absolute path and resolve any symlinks.
)
if(CMAKE_SYSTEM_NAME STREQUAL "Android" AND IS_DIRECTORY "${PROJECT_BREEZEICONS_DIR}")
    list(APPEND            BREEZEICONS_DIR "${PROJECT_BREEZEICONS_DIR}")

    # To prevent adding duplicates at each run of CMake, remove the duplicates again.
    list(REMOVE_DUPLICATES BREEZEICONS_DIR)

    # The variable is cached in ${BUILD_DIR}/CMakeCache.txt. We need FORCE to change it there
    # immediately. Also, add a comment to the cache file.
    set(BREEZEICONS_DIR ${BREEZEICONS_DIR}
        CACHE STRING "Path to the KDE Breeze icon set, for the Kirigami's Android packaging scripts"
        FORCE
    )
endif()

# Directories where Qt Creator can find QML files of Kirigami etc..
#
#   Needed to make Qt Creator code completion happy. Not needed for builds to succeed. In fact,
#   QML_IMPORT_PATH is ignored by the build process and only used by Qt Creator. See:
#   https://bugreports.qt.io/browse/QTBUG-55259 . So there is no need to adapt it by target
#   platform, just to give Qt Creator one set of directories to resolve QML imports.
#
#   For documentation of the technique here and instructions to make a local change for your
#   system only, see https://stackoverflow.com/a/62202304
#
# Kirigami QML path for Ubuntu systems.
list(APPEND            QML_IMPORT_PATH "/usr/lib/x86_64-linux-gnu/qt5/qml")
# To prevent adding duplicates at each run of CMake, remove the duplicates again.
list(REMOVE_DUPLICATES QML_IMPORT_PATH)
# The variable is cached in ${BUILD_DIR}/CMakeCache.txt. We need FORCE to change it there
# immediately. Also, add a comment to the cache file.
set(QML_IMPORT_PATH ${QML_IMPORT_PATH}
    CACHE STRING "Qt Creator 4.1 extra QML import paths"
    FORCE
)

# Enable Qt MOC (Meta Object Compiler) pre-processor to run on C++ source files when needed.
# TODO: Remove if it turns out to be unnecessary. Only needed when using Q_OBJECT macros in our code.
set(CMAKE_AUTOMOC ON)
set(AUTOMOC_MOC_OPTIONS "-Muri=org.kde.kirigami")

# Set compilation flags.
add_definitions(
    # Needed for linking with the ZXing library starting from a certain commit between
    # 1.0.7 and 1.0.8. Because ZXing code throws exceptions.
    -fexceptions

    # Helps to catch implicit conversion of filenames to URLs by making it illegal, so you can
    # write code to properly convert to a file:// URL or something. See documentation at:
    # https://doc.qt.io/qt-5/qurl.html#QT_NO_URL_CAST_FROM_STRING
    -DQT_NO_URL_CAST_FROM_STRING
)

# Enable C++11 features for clang and gcc.
set(CMAKE_CXX_STANDARD 11)


# ################# CMake module includes ##########################################################

# include()s have to be up here because the new CMake functionality can only be used afterwards.

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


# ################# Application dependencies (CMake packages, QML modules) #########################

# Find the Qt installation.
find_package(
    Qt5 ${REQUIRED_QT_VERSION}
    REQUIRED
    NO_MODULE
    COMPONENTS
        Core
        Gui
        Qml
        QuickControls2
        Svg
        Sql
        Multimedia # Needed by the barcode scanner.
        Concurrent # Needed by the barcode scanner.
        Quick      # Needed by the barcode scanner.
)

# Require the package providing library Qt5::AndroidExtras, as needed in src/CMakeLists.txt.
if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(Qt5AndroidExtras ${REQUIRED_QT_VERSION} REQUIRED)
endif()

# Find Kirigami and other relevant KDE components.
find_package(KF5Kirigami2 REQUIRED)
# find_package(KF5I18n) # TODO: Add when starting to use i18n.

# Find ZXing C++ (a C++ reimplementation of popular barcode scanner library ZXing).
#   Source: https://github.com/nu-book/zxing-cpp.
#
#   Current ZXing version requirements: minimum version zxing-cpp commit 57c4a89 (which is 1.0.8
#   plus some commits), because the CMake package versioning support was introduced here.
#
#   TODO: Switch to find_package(ZXing 1.0.9 REQUIRED) once that release is out, and then drop the
#   additional commit version requirement from above and README.md.
find_package(ZXing 1.0.8 REQUIRED)

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
