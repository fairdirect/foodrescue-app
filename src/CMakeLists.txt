# ################# Lists to maintain manually #####################################################

# Application C++ source files to compile.
#   If you have a .cpp file that includes a corresponding .h file, only add the .cpp file.
#   If you have a .h file without a corresponding .cpp file, add that .h file. Otherwise,
#   Qt's MOC will not know about that .h file (even though it's included from other files!)
#   and fail to generate a *_moc.cpp file for it. That would lead to hard to debug errors,
#   such as "undefined reference to "Something::staticMetaObject".
set(foodrescue_SRCS
    main.cpp
    utilities.cpp
    ContentDatabase.cpp
    History.cpp
    LocaleChanger.cpp
    ZXingQtReader.h
)

# Qt Resource Collection (.qrc) files.
#   Files listed in .qrc files will be bundled into the executable.
qt5_add_resources(RESOURCES
    resources.qrc
)

# Dynamic libraries to link with the Android executable only (as they are only needed there).
#
#   These libraries are then linked with the executable below, see at:
#   target_link_libraries(foodrescue … ${foodrescue_EXTRA_LIBS})
#
#   This mechanism is different from ANDROID_EXTRA_LIBS (https://phabricator.kde.org/D13198) which
#   is meant to include libraries into the APK that are NOT directly linked with the executable.
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    # Require the package that provides the Kirigami library we want to include.
    find_package(KF5Kirigami2 ${KF5_DEP_VERSION} REQUIRED)

    # This variable is used below in target_link_libraries(…).
    set(foodrescue_EXTRA_LIBS
        # TODO: Why is this only needed on Android? It should be necessary for the whole application.
        # If so, it should be moved to target_link_libraries(foodrescue …) below.
        Qt5::QuickControls2

        # TODO: Why is this only needed on Android? It should be necessary for the whole application.
        # If so, it should be moved to target_link_libraries(foodrescue …) below.
        KF5::Kirigami2

        # A Qt component library required by the Kirigami plugin.
        # TODO: Why is this only needed on Android? It should be necessary for the whole application.
        # If so, it should be moved to target_link_libraries(foodrescue …) below.
        # TODO: Should not be needed, but without this the library is not in the APK and we get
        # "dlopen failed: library libQt5Concurrent.so not found" when the Android app starts.
        # TODO: Give this library in the namespace naming format. Probably Qt5::Concurrent, but it
        # does not work yet. Probably because find_package(Qt5 …) needs a component added, which
        # might not be named "Concurrent".
        /opt/qt/5.12.4/android_armv7/lib/libQt5Concurrent.so

        # TODO: Is this used at all?
        Qt5::AndroidExtras
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
        view-barcode
        star-shape
        system-search
    )
endif()


# ################# Compilation and installation ###################################################

# Define executable to generate, and its required inputs.
#   Represented as "[hammer icon] foodrescue" in the Qt Creator project outline.
#
#   Order is important: this has to come after all include_directories() and link_directories()
#   relevant for this command.
add_executable(foodrescue ${foodrescue_SRCS} ${RESOURCES})

# List of libraries that have to be linked with the executable, whether dynamically or statically.
#
#   This provides the compiler with include dir paths and the linker with library paths.
#
#   Use ONLY names with double colons "::" in this list. That makes sure you use targets provided
#   by find_package(…) above. Otherwise there is a fallback mechanism that will fails when the
#   library is installed in a custom location (as necessary for Android for example). Details:
#   https://github.com/nu-book/zxing-cpp/issues/132
target_link_libraries(foodrescue
    Qt5::Core
    Qt5::Quick
    Qt5::Qml
    Qt5::Svg         # For Breeze icons, among other purposes.
    Qt5::Sql
    Qt5::Multimedia  # For the barcode scanner.
    Qt5::Gui         # For the barcode scanner.
    Qt5::Concurrent  # For Kirigami.
    Qt5::Xml         # For formatted XML debug output. TODO: Avoid in non-debug builds.
    Qt5::XmlPatterns # For XSLT conversion of database contents for rendering.
    ZXing::ZXing     # For the barcode scanner.
    # KF5::I18n      # TODO: Add when starting to use KDE i18n. So far we use Qt i18n.
    ${foodrescue_EXTRA_LIBS}
)

# Install the binary generated by this makefile.
install(TARGETS foodrescue ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
