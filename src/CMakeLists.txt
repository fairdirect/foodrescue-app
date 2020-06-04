# ------------------------- BEGIN: lists to maintain manually -------------------------

# Define the application source files to be compiled.
set(foodrescue_SRCS
    main.cpp
)

# Bundle the files listed in Qt Resource Collection (.qrc) files.
qt5_add_resources(RESOURCES
    resources.qrc
)

# Define libraries to bundle and link with the application.
#   (Needed on Android only, as desktop systems should supply these system-wide.)
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(KF5Kirigami2 ${KF5_DEP_VERSION})
    set(foodrescue_EXTRA_LIBS Qt5::AndroidExtras
        KF5::Kirigami2
        KF5::I18n # TODO: Remove if not using KDE i18n.
        # FIXME: Linking with QQC2 should not be needed. But if we don't, the lib will not be
        # included into the Android APK package.
        Qt5::QuickControls2
    )
endif()

# Include in-use Breeze icons with the Android APK package.
#   To browse available icons to choose from, execute as per https://askubuntu.com/a/1246673 :
#   pcmanfm-qt "search:///usr/share/icons/breeze?recursive=1&name_regex=*&mime_types=image/*"
#
#   Also note that some Breeze icons are used by Kirigami components themselves and already
#   packaged. They can be re-used in the application without increasing file size. For
#   Kirigami 5.68.0, these icons are:
#     go-next go-previous go-up handle-sort overflow-menu-left overflow-menu-right
#     go-next-symbolic go-next-symbolic-rtl go-previous-symbolic go-previous-symbolic-rtl
#     overflow-menu user view-left-new view-right-new view-left-close view-right-close
#   Source: https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/KF5Kirigami2Macros.cmake#L15
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(KF5Kirigami2 REQUIRED)
    kirigami_package_breeze_icons(ICONS
        configure
        dialog-warning
        help-about
    )
endif()

# ------------------------- END: lists to maintain manually -------------------------


# Generate KDE AppStream meta information about the application, to integrate it with KDE.
#   (This is not an essential build step though. Disable when not working.)
find_program(kpackagetool_cmd kpackagetool5)
if (kpackagetool_cmd)
    set(component org.fairdirect.foodrescue)
    set(APPDATAFILE "${CMAKE_CURRENT_BINARY_DIR}/${component}.appdata.xml")

    message(STATUS "${kpackagetool_cmd} --appstream-metainfo ${CMAKE_CURRENT_SOURCE_DIR}/data --appstream-metainfo-output ${APPDATAFILE}")
    execute_process(
        COMMAND ${kpackagetool_cmd} --appstream-metainfo ${CMAKE_CURRENT_SOURCE_DIR} --appstream-metainfo-output ${APPDATAFILE}
        ERROR_VARIABLE appstreamerror
        RESULT_VARIABLE result
    )

    if (NOT result EQUAL 0)
        message(WARNING "couldn't generate metainfo for ${component}: ${appstreamerror}")
    else()
        if(appstreamerror)
            message(WARNING "warnings during generation of metainfo for ${component}: ${appstreamerror}")
        endif()

        install(
            FILES ${APPDATAFILE}
            DESTINATION ${KDE_INSTALL_METAINFODIR}
            OPTIONAL # Because "NoDisplay" .desktop files will render no XML.
        )
    endif()
else()
    message(WARNING "Could not find command kpackagetool5. Appstream information won't be generated for ${component}.")
endif()

# Define executable to generate, and its required inputs.
#   (Represented as "[hammer icon] foodrescue" in the Qt Creator project outline.)
add_executable(foodrescue ${foodrescue_SRCS} ${RESOURCES})

# Link all required libraries with the executable.
target_link_libraries(foodrescue
    # TODO: Why are some Qt libraries here and some in ${foodrescue_EXTRA_LIBS}? No Qt
    # library should need bundling for desktop targets, so all should be extra libs (only
    # included for Android builds), no?
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Svg
    ${foodrescue_EXTRA_LIBS}
)

# Install the binary generated in this makefile.
install(TARGETS foodrescue ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
