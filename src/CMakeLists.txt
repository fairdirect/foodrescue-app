# ------------------------- BEGIN: lists to maintain manually -------------------------

# Define the application source files to be compiled.
set(foodrescue_SRCS
    main.cpp
)

# Define Qt Resource Collection (.qrc) files, to include the resource files listed there.
qt5_add_resources(RESOURCES
    resources.qrc
)

# Define libraries to link statically with the application.
#   (Needed on Android only, as desktop systems should supply these system-wide.)
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(KF5Kirigami2 ${KF5_DEP_VERSION})
    set(foodrescue_EXTRA_LIBS Qt5::AndroidExtras
        KF5::Kirigami2
        # FIXME: Linking with QQC2 should not be needed. But if we don't, the lib will not be
        # included into the Android APK package.
        Qt5::QuickControls2
    )
endif()

# Include in-use icons with the Android APK package.
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_package(KF5Kirigami2 REQUIRED)
    kirigami_package_breeze_icons(ICONS
        applications-graphics
        configure
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

# Define the name of the executable.
add_executable(foodrescue ${foodrescue_SRCS} ${RESOURCES})

# Link all required libraries with the executable.
target_link_libraries(foodrescue
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Svg
    ${foodrescue_EXTRA_LIBS}
)

# What files to install during deploys (the executable and KDE's .desktop file).
install(TARGETS foodrescue ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
install(
    FILES metadata.desktop
    DESTINATION ${XDG_APPS_INSTALL_DIR}
    RENAME org.fairdirect.foodrescue.desktop
)
