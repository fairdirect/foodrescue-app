# ################# Lists to maintain manually #####################################################

# Application C++ source files to compile.
set(foodrescue_SRCS
    main.cpp
    utilities.cpp
    ContentDatabase.cpp
    QZXingNu.cpp
    QZXingNuFilter.cpp
)

# Qt Resource Collection (.qrc) files.
#   Files listed in .qrc files will be bundled into the executable.
qt5_add_resources(RESOURCES
    resources.qrc
)

# Dynamic libraries to include into the Android APK package.
#   Libraries can be identified via the library name you'd give to "g++ -l…" or as absolute paths.
#   Library names are preferable as they work across systems.
#
#   Not meant for libraries that are automatically included by being referred to from the
#   executable: "This can be used to include plugins that are not directly liked to executable, for
#   example OpenSSL libs for QtNetwork SSL/HTTPS support." (https://phabricator.kde.org/D13198).
#
#   Not meant for desktop Linux systems, which will supply these libraries system-wide via package
#   dependencies. TODO: What happens on iOS, Windows and Mac OS X?
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    # Require the package that provides the Kirigami library we want to include.
    find_package(KF5Kirigami2 ${KF5_DEP_VERSION} REQUIRED)

    # This variable is used below in target_link_libraries(…).
    set(foodrescue_EXTRA_LIBS
        # TODO: Including QQC2 this way should not be needed, as it is directly linked from the
        # executable. Try if without this, the library still lands in the APK.
        Qt5::QuickControls2

        # TODO: Should not be needed, but without this the library is not in the APK and we get
        # "dlopen failed: library libQt5Concurrent.so not found" when the Android app starts.
        # TODO: How to give the library in the named format? Qt5::Concurrent does not work.
        /opt/qt/5.12.4/android_armv7/lib/libQt5Concurrent.so

        # TODO: Should not be needed, but without this the library is not in the APK and we get
        # "dlopen failed: library libKF5Kirigami2.so not found" when the Android app starts.
        KF5::Kirigami2

        # TODO: Is this used at all? And if so, do we need to include it via extra libs?
        Qt5::AndroidExtras

        # TODO: Add when starting to use KDE i18n.
        # TODO: Including KDE I18n this way should not be needed, as it is directly linked from the
        # executable. Try if without this, the library still lands in the APK.
        # KF5::I18n
    )
endif()

# Icons to package with the Android APK, specified using FreeDesktop icon names.
#
#   The FreeDesktop Icon Naming Spec lists all available icon names that can be used here:
#   https://specifications.freedesktop.org/icon-naming-spec/icon-naming-spec-latest.html#names
#   To browse available icons to choose from, see: https://commons.wikimedia.org/wiki/Comparison_of_icon_sets
#
#   On Linux desktop systems, the application can use all icons from the user's current Qt icon
#   theme. No need to bundle icons here, as the application package will depend on an icon theme
#   being installed. But on Android, there is no system-wide icon theme, so you have to list the
#   icons that your application uses.
#
#   The icons bundled into the Android APK here are from "Breeze", the default KDE5 icon theme.
#
#   TODO: What happens when building for on iOS, Windows and Mac OS X?
#
#   Some Breeze icons are used by Kirigami components themselves and always bundled into an Android
#   APK. They can be re-used in the application without increasing file size. For Kirigami 5.68.0,
#   these icons are:
#     go-next go-previous go-up handle-sort overflow-menu-left overflow-menu-right
#     go-next-symbolic go-next-symbolic-rtl go-previous-symbolic go-previous-symbolic-rtl
#     overflow-menu user view-left-new view-right-new view-left-close view-right-close
#   Source: https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/KF5Kirigami2Macros.cmake#L15
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    # Require the package providing kirigami_package_breeze_icons().
    find_package(KF5Kirigami2 REQUIRED)

    # TODO: Why don't we have to do include(KF5Kirigami2Macros) before using
    # kirigami_package_breeze_icons()?

    kirigami_package_breeze_icons(ICONS
        configure
        dialog-warning
        help-about
    )
endif()


# ################# Compilation and installation ###################################################

# Tell the compiler where to find the header files of the ZXingCore library.
#   The swex/zxing-cpp fork used here does not support the find(ZXingCore) mechanism. So this is
#   unfortunately the only option right now. See https://github.com/swex/zxing-cpp/
#
#   Do NOT put this into this project's source tree for inclusion with
#   add_subdirectory(…). That provides a different environment for compilation, resulting in a
#   failure to compile zxing-cpp.
include_directories(/home/matthias/Projects/Fairdirect.Food_Rescue_App/Repo.qzxingnu)

# Tell the linker where it can find the ZXingCore library mentioned below.
#   The swex/zxing-cpp fork used here does not support the find(ZXingCore) mechanism. So this is
#   unfortunately the only option right now. See https://github.com/swex/zxing-cpp/
link_directories(
    /home/matthias/Projects/Fairdirect.Food_Rescue_App/Repo.qzxingnu/build/My_Desktop_Kit_for_Kirigami.Release/zxing-cpp/core
)

# Define executable to generate, and its required inputs.
#   Represented as "[hammer icon] foodrescue" in the Qt Creator project outline.
#
#   Order is important: this has to come after all include_directories() and link_directories()
#   relevant for this command.
add_executable(foodrescue ${foodrescue_SRCS} ${RESOURCES})

# Link all required libraries with the executable.
target_link_libraries(foodrescue
    # TODO: Why are some Qt libraries here and some in ${foodrescue_EXTRA_LIBS}? No Qt
    # library should need bundling for desktop targets, so all should be extra libs (only
    # included for Android builds), no?
    Qt5::Core
    Qt5::Quick
    Qt5::Qml
    Qt5::Svg
    Qt5::Sql
    Qt5::Multimedia  # Needed for the barcode scanner.
    Qt5::Gui         # Needed for the barcode scanner.
    Qt5::Concurrent  # Needed for the barcode scanner.
    ZXingCore        # Needed for the barcode scanner.
    ${foodrescue_EXTRA_LIBS}
)

# Install the binary generated by this makefile.
install(TARGETS foodrescue ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
