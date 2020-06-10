# Food Rescue App

🍒🍌🥕🥑🍐🍅🍈🍓🥜🌮🥚🍞🍒🍌🥕🥑🍐🍅🍈🍓🥜🌮🍞🍒🍌🥕🥑🍐🍅🍈🍓🥜🍞🍒🍌🥕🥑🍐🍅🍈🍓🍞🍒

&nbsp;


🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧

**This application is under construction.**

The code does not provide a useful application just yet. Check back at 2020-08-31 to find the first full release here, or a few weeks earlier for beta releases.

🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧


**[1. Overview](#1-overview)**<br/>
**[2. Repository Structure](#2-repository-structure)**<br/>
**[3. Installation](#3-installation)**<br/>
**[4. Usage](#4-usage)**<br/>
**[5. Development](#5-development)**

  * [5.1. Dependencies Overview](#51-dependencies-overview)
  * [5.2. Desktop Development Setup](#52-desktop-development-setup)
  * [5.3. Desktop Build Process](#53-desktop-build-process)
  * [5.4. Android Development Setup](#54-android-development-setup)
  * [5.5. Android Build Process](#55-android-build-process)
  * [5.6. Qt Creator Setup](#56-qt-creator-setup)

**[6. Release Process](#6-release-process)**<br/>
**[7. Style Guide](#7-style-guide)**

  * [7.1. Code Style](#71-code-style)
  * [7.2. Documentation Style](#72-documentation-style)
  * [7.3. Software Design](#73-software-design)

**[8. Contribution Guide](#8-contribution-guide)**<br/>
**[9. License and Credits](#9-license-and-credits)**

------


# 1. Overview

This repository contains an open source application to help assess if food is still edible or not. The actual content shown inside this application is contained and processed in repository [foodrescue-content](https://github.com/fairdirect/foodrescue-content).

**Features:**

* **Convergent.** The application runs from the same codebase and with the same user interface as a native (!) application on both phones, tablets and desktop computers. This is made possible by Qt5 and, based on that, the [KDE Kirigami](https://kde.org/products/kirigami/) framework.

* **Cross-platform.** The application is cross-platform, running on all platforms supported by the KDE Kirigami framework. As of 2020-06, these are: Android, iOS, Windows, Mac OS X, Linux, FreeBSD ([see](https://invent.kde.org/frameworks/kirigami/-/blob/master/metainfo.yaml#L5)).

* **Scan to check.** To quickly find the required information about a food item, scan its GTIN barcode with the camera of your device.

* **Keyboard control.** The application can be fully controlled by keyboard shortcuts. That also works in the mobile variant, such as for Android based netbooks.

* **Desktop touch control.** As a side effect of convergent application development, the user interface is touch control friendly even on the desktop version. That's useful for the considerable amount of notebook computers with touchscreens.


**Documentation:**

* **Project website.** The project's website with introductory information and relevant links is [fairdirect.org/food-rescue-app](https://fairdirect.org/food-rescue-app).

* **API documentation.** The project's C++ source files contain in-code documentation that you can compile into full API docs with [Doxygen](https://www.doxygen.nl/).

* **Other documentation.** Extensive project documentation about planned features, used technologies, frequent tasks and related projects and initiatives is available as a Dynalist document ["Food Rescue App Documentation"](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA). The same content is also available as an exported version under `doc/doc.html` in this repository. But the export is still rough and does not support proper navigation in the document, so at this time the Dynalist live document is preferable.


# 2. Repository Structure

TODO


# 3. Installation

Right now, you would have to compile the software yourself from source ☹️ See chapter [5. Development](#5-development) for that.

Eventually you will be able to install the software comfortably as follows:

* **For Android.** Install directly from [F-Droid](https://f-droid.org/) or [Google Play](https://play.google.com/store/apps). Or install from the [KDE Android F-Droid repository](https://community.kde.org/Android/FDroid), which also contains all other Kirigami based Android applications.

* **For iOS.** Install from the Apple App Store.

* **For Linux.** For Ubuntu 20.04 LTS and its variants, a Debian package is provided in a PPA package repository.

* **For Windows.** Download a self-extracting installer and install from there.

* **For Mac OS X.** Download a DMG package and install from there.


# 4. Usage

The following keyboard combinations are available:

* **Close the application.** Ctrl + Q (Kirigami default)
* **Select menu item.** Alt + highlighted letter while menu drawer is open

TODO: Complete usage instructions.


# 5. Development

The following chapters provide a setup to build Food Rescue App under Ubuntu Linux 20.04 LTS. The instructions are mostly the same under Ubuntu 19.10 and under other Ubuntu flavors and other [Debian (Testing) based Linux distributions](https://en.wikipedia.org/wiki/List_of_Linux_distributions#Debian_%28Testing%29_based). But if you are setting up your development environment under Windows or Mac OS X, you are so far on your own; you can however learn the required versions of Android SDK, NDK, Qt, KDE ECM and Kirigami from the instructions below.


## 5.1. Dependencies Overview

The dependencies of Food Rescue App are chosen to be matched by the newest current Ubuntu LTS release. So for example, Food Rescue App releases between 2020-04 and 2022-04 ([see](https://ubuntu.com/about/release-cycle)) will be installable under Ubuntu 20.04 LTS and you will be able to use default Ubuntu 20.04 LTS repository packages for its development. If your distribution provides older versions of the dependencies listed below, or you develop under Windows or Mac OS X, you have to install dependencies manually. There are a few exceptions from this rule of sticking to Ubuntu LTS packages:

* The project currently also builds under Ubuntu 19.10, but that is not guaranteed for the future.
* In cases where a version of Food Rescue App needs a package in a newer version than provided in the current Ubuntu LTS release, it will use the package versions provided in [Kubuntu Backports](https://launchpad.net/~kubuntu-ppa/+archive/ubuntu/backports). These might be not the latest releases either, but are easy to add on top of a normal Ubuntu distribution by adding a PPA. In contrast, KDE Neon is a Ubuntu LTS based distribution providing the most cutting edge versions, but adding that on top of a usual Ubuntu installation is messy and can lead to dependency hell.


#### Dependencies for Android development

When only building the desktop version of this application, any Qt >5.12 will fulfill the requirements of Kirigami and should work with the tooling provided by your Linux distribution. When you also want to build the Android application, it gets complicated. For Ubuntu 20.04 LTS, it is the safest to follow the development setup instructions in this document to end up with the right versions (the desktop development setup already chooses versions that can also be used for Android development). If you need other versions, see the table below.

To find out the versions you have installed:

   ```
   apt-cache show extra-cmake-modules | grep "Version:"
   # TODO: version check for Android NDK and Qt
   ```

To find the version of [extra-cmake-modules](https://invent.kde.org/frameworks/extra-cmake-modules) ("ECM") you need for a chosen combination of Android NDK and Qt:

|                         | **NDK 18**    | **NDK 19**    | **NDK 20**    | **NDK 21** |
|-------------------------|---------------|---------------|---------------|------------|
| **Qt 5.12 for Android** | ECM ≥5.62.0   | n/a           | n/a           | n/a        |
| **Qt 5.13 for Android** | n/a           | n/a           | n/a           | n/a        |
| **Qt 5.14 for Android** | ECM ≥5.68.0   | n/a           | n/a           | n/a        |
| **Qt 5.15 for Android** | ?             | n/a           | n/a           | n/a        |

What makes the versions in the table necessary:

While the Android platform and Qt library interfaces are mature and almost always backwards compatible, this is not true for the build process. New versions of Android NDK and Qt often introduce changes that necessitate changing build tools that rely on them. For Kirigami, the Android build process is mostly handled by [KDE extra-cmake-modules](https://invent.kde.org/frameworks/extra-cmake-modules) ("ECM").

* **Android NDK 19 and 20 support.** Support for Android NDK 20 exists since ECM [commit c9ebd39](https://invent.kde.org/frameworks/extra-cmake-modules/commit/c9ebd39), corresponding to version 5.68.0. Since some of the changes that make Android NDK 20 incompatible with previous ECM versions are also present in NDK 19 ([see](https://github.com/LaurentGomila/qt-android-cmake/blob/5a62962/AddQtAndroidApk.cmake#L172)), we infer that ECM 5.68.0 or newer is needed for NDK 19 as well. However there is an additional issue (TODO: link) that makes ECM incompatible with Android NDK ≥19. As of 2020-06-10, there is no fix, as even the now-current version ECM 5.71.0 exhibits this issue.

* **Qt 5.13 support.** The [commit c9ebd39](https://invent.kde.org/frameworks/extra-cmake-modules/commit/c9ebd39) message tells that even in that version, Qt 5.13 has issues with "older NDKs", which we assume here to mean versions before Android NDK 19. In the commits until 2020-06-08, there is no indication that these issues were fixed.

* **Qt 5.14 support.** When trying Qt ≥5.14 for Android with ECM 5.62, you would see `androiddeployqt` fail during the build process with the error message "No target architecture defined in json file". This seems to be due to the same change in Qt that also caused the equivalent issues [#35](https://github.com/LaurentGomila/qt-android-cmake/issues/35) in [qt-android-cmake](https://github.com/LaurentGomila/qt-android-cmake) and [#23306](https://bugreports.qt.io/browse/QTCREATORBUG-23306) in the CMake scripts for Android deployment that come with Qt Creator. It has to be fixed in every set of CMake scripts that for Android deployment, and ECM is yet another one of these. It was fixed with ECM [commit c9ebd39](https://invent.kde.org/frameworks/extra-cmake-modules/commit/c9ebd39) – see the commit message there. That commit was on 2020-03-03 and the [Git tag list](https://invent.kde.org/frameworks/extra-cmake-modules/-/tags) shows it landed in 5.68.0.


## 5.2. Desktop Development Setup

1. **Install basic development tooling.** Under Ubuntu 20.04 LTS, install with:

     ```
     sudo apt install build-essential cmake
     ```

2. **Install ECM.** Under Ubuntu 20.04 LTS, you can install them with:

    ```
    sudo apt install extra-cmake-modules
    ```

    However, if you want to work with Qt ≥5.14 and / or Android NDK ≥19, you need ECM ≥5.68.0. In that case, install them with:

    ```
    git clone https://invent.kde.org/frameworks/extra-cmake-modules.git
    cd extra-cmake-modules

    # Adapt to the commit of a stable version ≥5.68.0, here 5.70.0. As seen on
    # https://invent.kde.org/frameworks/extra-cmake-modules/-/tags
    git checkout fca97c03

    mkdir build && cd build && cmake ..
    make

    # Adapt to the version you checked out, here 5.70.0.
    sudo checkinstall --pkgname extra-cmake-modules --pkgversion 5.70.0 make install
    ```

3. **Install KDE Kirigami 5.68.0 or higher.** [As provided](https://launchpad.net/ubuntu/focal/amd64/kirigami2-dev) under Ubuntu 20.04 LTS and installed there with:

    ```
    sudo apt install kirigami2-dev libkf5kirigami2-doc
    ```

    If you have to install Kirigami 5.68.0 manually, choose the corresponding commit `f47bf906` ([source](https://invent.kde.org/frameworks/kirigami/-/tags)). Avoiding a higher version can be necessary if it does not build with your system's Qt libraries otherwise.

    Note that KDE Kirigami is a lightweight library independent of the KDE Plasma desktop environment – it has no dependencies beyond Qt, and you don't need KDE Plasma installed to use it or develop for it.

4. **Install Qt 5.12.0 or up to 5.13.2.** Qt 5.12.0 or higher [is required](https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/CMakeLists.txt#L8) by KDE Kirigami 5.68.0. Under Ubuntu this is installed automatically as a [dependency of Kirigami](https://launchpad.net/ubuntu/focal/amd64/libkf5kirigami2-5/5.68.0-0ubuntu2). Ubuntu 20.04 LTS provides Qt 5.12.5 while Ubuntu 19.10 provides Qt 5.12.4 ([see](https://reposcope.com/package/qt5-default)).

    In principle, you could also install Qt 5.13 or higher. Qt 5.13 or higher for desktop Linux applications as installed here works fine out of the box. However, it is advisable to keep the Qt versions for desktop Linux and Android the same to avoid surprises. And when installing Qt 5.13 or higher for Android, additional steps will be needed, as detailed in chapter [5.4. Android Development Setup](#54-android-development-setup) below.

5. **Install the remaining Qt header files (optional).** To be able to access all components of Qt in your code without having to install more packaged on demand, you can install all the Qt header files already:

    ```
    sudo apt install libqt5gamepad5-dev libqt5opengl5-dev libqt5sensors5-dev libqt5serialport5-dev libqt5svg5-dev libqt5websockets5-dev libqt5x11extras5-dev libqt5xmlpatterns5-dev qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev qtdeclarative5-dev-tools qtlocation5-dev qtpositioning5-dev qtquickcontrols2-5-dev qtscript5-dev qttools5-dev qttools5-dev-tools qtwayland5-dev-tools qtxmlpatterns5-dev-tools
    ```


## 5.3. Desktop Build Process

You can also build this the Android application from inside Qt Creator. See chapter [5.6. Qt Creator Setup](#56-qt-creator-setup).

1. **Get the application source code** by cloning its repository:

    ```
    git clone git@github.com:fairdirect/foodrescue-app.git
    ```

2. **Build the application.**

    ```
    cd foodrescue-app
    mkdir -p build/Desktop.CommandLineBuild && cd build/Desktop.CommandLineBuild
    cmake ../..
    cmake --build .

    # Optional: if you don't want to trun the binary in place.
    make install
    ```

    As an alternative to `cmake --build .`, you can also simply run `make`, because CMake is a tool that generates GNU Make makefiles.


## 5.4. Android Development Setup

1. **Make the development setup for the desktop version.** Follow all steps from chapter "[5.2. Desktop Version Development Setup](#52-desktop-version-development-setup)". Make sure you can build and execute a desktop version; you can also do that during Android development to quickly test code that is not Android-specific.

2. **Install OpenJDK 8.** This is a dependency of the Android stack and of Qt Creator. Later versions will not work – [see](https://doc.qt.io/qtcreator/creator-developing-android.html#requirements). And when not doing the `update-alternatives` step, command line utilities that do not inherit the Qt Creator Java path (such as `sdkmanager` when started manually) will fail to run.

    ```
    sudo apt install openjdk-8-jdk
    sudo update-alternatives --config java
    ```

3. **Install `sdk-tools-linux-4333796.zip`.** Do not install the new edition of this, called "commandlinetools 1.0" as provided on the [Android Studio download page](https://developer.android.com/studio) ([reasons](https://stackoverflow.com/a/62073804)).
Download and unpack the package to the place that will later also host the Android SDK:

    ```
    cd /opt/android-sdk/
    wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
    unzip sdk-tools-linux-4333796.zip
    ```

    Make the `sdkmanager` command accessible system-wide:

    ```
    sudo ln -s /opt/android-sdk/tools/bin/sdkmanager /usr/local/bin/
    ```

4. **Install the Android stack.** Use the now-installed `sdkmanager` to download the SDK packages required for Android development ([source](https://doc.qt.io/qtcreator/creator-developing-android.html#requirements)).

    Choose an Android SDK platform (like `platforms;android-29`) that provides at least the API level of your device. Choosing a newer SDK here is no problem, as restricting created APK packages to require a lower API level for installation is possible. The API level number supported by your Android testing device can be found [here](https://developer.android.com/studio/releases/platforms).


    The version of the build tools has to correspond to the version of the Android SDK platform, but will not be the same version. For example in the versions chosen below, indeed, build tools 28.0.2 are required to go together with Android platform SDK 29. The requirements can be found on [this page](https://developer.android.com/studio/releases/platforms).

    According to the [official Qt Creator installation instructions](https://doc.qt.io/qtcreator/creator-developing-android.html#setting-up-the-development-environment), for Qt 5.12.0 to 5.12.5 (which we use here), the correct versions of Android stack packages are installed with the commands below. Except, we stick with Android NDK 18 due to an open issue (TODO: link) in KDE's `extra-cmake-modules` with finding the C++ standard library when using Android NDK ≥19.

    ```
    sdkmanager --install "platform-tools" "platforms;android-29" "build-tools;28.0.2" "ndk;18.1.5063045"
    ```

    Then batch-accept the licences ([see](https://stackoverflow.com/a/4682241)):

    ```
    yes | sdkmanager --licenses
    ```

5. **Install Qt for Android.** Needed because the Ubuntu repositories contain only the desktop variant "Qt 5.12.5 (GCC 5.3.1 … 64 bit)". For Android, we need a variant compiled for ARMv7 / ARMv8 architecture instead. The below is the most comfortable way to install Qt for Android; for other options, [see here]( (https://stackoverflow.com/a/62090264).

    1. **Install [`aqtinstall`](https://github.com/miurahr/aqtinstall/).** This is an unofficial installer to install any platform version of Qt on any platform. This is needed because the version of Qt provided in the Ubuntu repositories does not provide the Qt Maintenance Tool that could be used as an alternative.

    2. **Install Qt for Android.** Use `aqtinstall` to install Qt 5.12.5 for Android. This is the version contained in Ubuntu 20.04 LTS, matching the version you use for desktop development. Matching versions exactly is not strictly necessary, but avoids surprises and keeping two sets of documentation at hand.

        You can also install Qt 5.13 for Android or higher, but will need additional steps: for Qt 5.13.x or higher, you have to update your `extra-cmake-modules` package manually to 5.68.0 (see chapter [5.1. Version Compatibility Matrix](#51-version-compatibility-matrix)); and for Qt 5.14 or higher additionally you have to [adapt the Android Manifest file](https://stackoverflow.com/a/62108461) of this application. For Qt 5.15, additional steps may be necessary as that has not been tested yet. The next version after Qt 5.15 will probably be Qt 6, to which Kirigami and this application would have to be ported first.

6. **Build Kirigami for Android.** We want to cross-compile an application for Android that depends on Kirigami. Ubuntu repositories do not provide Kirigami built for Android, so we have to do that ourselves. Instructions are mostly [from here](https://community.kde.org/Marble/AndroidCompiling#Setting_up_Kirigami).

    1. Clone the repository to a local directory `kirigami`:

        ```
        git clone https://invent.kde.org/frameworks/kirigami.git
        ```

    2. To get Kirigami 5.68.0, the same version as installed for desktop appliction development under Ubuntu 20.04, choose the corresponding commit `f47bf906` ([source](https://invent.kde.org/frameworks/kirigami/-/tags)):

        ```
        cd kirigami
        git checkout f47bf906
        ```

    3. Run CMake with the environment variables it requires:

        ```
        export ANDROID_SDK_ROOT=/opt/android-sdk
        export ANDROID_NDK=/opt/android-sdk/ndk/19.2.5345600
        export ANDROID_ARCH_ABI=armeabi-v7a
        export ANDROID_PLATFORM=23 # TODO: Might not be required.

        cmake .. -DCMAKE_TOOLCHAIN_FILE=/usr/local/share/ECM/toolchain/Android.cmake -DCMAKE_PREFIX_PATH=/opt/qt/5.12.4/android_armv7 -DCMAKE_INSTALL_PREFIX=../export -DECM_DIR=/usr/local/share/ECM/cmake
        ```

    4. Build and install to the `CMAKE_INSTALL_PREFIX` directory:

        ```
        make
        make install
        ```

7. **Install Breeze icons.** Used for the icons packaged into the Android APK.

    1. **Install the icon theme.** Under Ubuntu 20.04 LTS, install it with:

        ```
        sudo apt install breeze-icon-theme
        ```

        This is not strictly necessary. The build system will [clone the Breeze repository](https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/KF5Kirigami2Macros.cmake#L63)
if it's not found. But it's cleaner to install this way, and allows to preview the same icons when compiling the desktop application.

    2. **If not on Ubuntu: configure `BREEZEICONS_DIR` in Qt Creator.** CMake variable `BREEZEICONS_DIR` is needed for CMake to find your Breeze icon theme. Otherwise it will clone the Breeze repository. For Ubuntu, this application already defines `BREEZEICONS_DIR` using [this technique](https://stackoverflow.com/a/62202304). If you did not install from the Ubuntu packages, define `BREEZEICONS_DIR` yourself following [these instructions](https://stackoverflow.com/a/62222947).

    3. **Configure Qt desktop applications to use Breeze icons.** When developing for Android, compiling and testing changes on the desktop application first is a good way to speed up development. In order to look as much as possible like the Android UI, you want your Qt desktop applications to also use the Breeze icons that get packaged into the Android package.

        This is not guaranteed: Breeze is the default icon theme in KDE Plasma, but if you don't use KDE Plasma then another tool could have selected a different icon theme. And when starting, any Kirigami application like Food Rescue App will simply pick up the Qt icon theme in use.

        The places to change the icon theme are as follows:

        * **If you use Lubuntu (LXQt):** In `lxqt-config-appearance`, select "Icons Theme → Breeze".
        * **If you use KDE:** Breeze is the default icon theme, but maybe you changed it before. There is a nice command line way to change it back: `lookandfeeltool -a org.kde.breeze.desktop`.
        * **If you use another desktop environment:** Change the icon theme in the ways your desktop environment wants it to be done. Qt applications should pick up this change.
        * **If nothing else works:** Install the Qt5 Configuration Tool (`sudo apt install qt5ct`) and in tab "Icon Theme" select "Breeze".

8. **Adapt the makefile.** Due to open issues with the build process, right now you have to adapt `src/CMakeLists.txt` to your system as follows:

    * In `set(foodrescue_EXTRA_LIBS …)` adapt the path to `libQt5Concurrent.so` for your system.


## 5.5. Android Build Process

You can also build this the Android application from inside Qt Creator. See chapter [5.4. Qt Creator configuration](54-qt-creator-configuration).

The following instructions create an APK package successfully, but the application fails to start under Android. TODO: Fix the instructions to provide a working build.

1. **Get the application's source code** by cloning its repository:

    ```
    git clone git@github.com:fairdirect/foodrescue-app.git
    ```

2. **Run CMake with the environment variables it requires.** Here, "`-DCMAKE_INSTALL_PREFIX` folder will be the same as where kirigami [built for Android] was installed, since you need to create an apk package that contains both the kirigami build and the build of your application" ([source](https://invent.kde.org/frameworks/kirigami#build-on-your-application-android-ship-it-together-kirigami)). Similarly, `KF5Kirigami2_DIR` is an absolute path to the Kirigami library contained in that build of Kirigami for Android in the location where it was installed.

    ```
    export ANDROID_SDK_ROOT=/opt/android-sdk
    export ANDROID_NDK=/opt/android-sdk/ndk/19.2.5345600
    export ANDROID_ARCH_ABI=armeabi-v7a
    export ANDROID_PLATFORM=23 # TODO: Check if this is required.

    mkdir -p build/Android.ConsoleBuild && cd build/Android.ConsoleBuild

    cmake ../.. -DQTANDROID_EXPORTED_TARGET=foodrescue -DANDROID_APK_DIR=./src -DECM_DIR=/usr/local/share/ECM/cmake -DCMAKE_TOOLCHAIN_FILE=/usr/local/share/ECM/toolchain/Android.cmake -DECM_ADDITIONAL_FIND_ROOT_PATH=/opt/qt/5.12.4/android_armv7 -DCMAKE_PREFIX_PATH=/opt/qt/5.12.4/android_armv7 -DANDROID_SDK_BUILD_TOOLS_REVISION=28.0.2 -DCMAKE_INSTALL_PREFIX=/path/to/kirigami/export -DKF5Kirigami2_DIR=/path/to/kirigami/export/lib/cmake/KF5Kirigami2
    ```

3. **Build the application.** (You could also just `make` first to see if the compilation step is successful.)

    ```
    make create-apk
    ```

4. **Install the application to your Android device.** First enable `adb` debug mode on your Android device, pair it with `adb` on the computer, and then execute:

    ```
    make install-apk-foodrescue
    ```


## 5.6. Qt Creator Setup

### Building the Food Rescue App Linux desktop application

1. **Install Qt Creator.** Under Ubuntu 20.04 LTS, you can:

    ```
    sudo apt install qtcreator qtcreator-doc
    ```

2. **Open the project.** In Qt Creator, go to "File → Open File or Project…" and open the project's `CMakeLists.txt`.

3. **Configure the build targets.** Select the "Projects" tab from the sidebar and configure the project's build targets (TODO: how).

4. **Build and run the application.** In the lower left build control toolbar, select your build target and then click the large green "Run" button.


### Building the Food Rescue App Android application

We could not yet build Food Rescue App for Android with Qt Creator. The instructions below are still incomplete.

TODO: Finish the instructions, and test them for Food Rescue App.

1. **Install Qt Creator.** ⚠️ ⚠️ Exceptionally, the instructions here use Qt Creator 4.12.1, not the Ubuntu 20.04 LTS provided version. Because Qt Creator 4.12 introduced major improvements in the Android build process. You can install Qt Creator 4.12.1 with [`aqtinstall`](https://github.com/miurahr/aqtinstall/) as follows:

    ```
    # TODO: installation instructions
    ```

    If you rather want to use Qt Creator from the Ubuntu repositories, you can do the following instead. It will give you Qt Creator 4.11.0 under Ubuntu 20.04 LTS ([see](https://launchpad.net/ubuntu/focal/+package/qtcreator)) and Qt Creator 4.8 under Ubuntu 19.10 (ca. 14 months older, [see](https://packages.ubuntu.com/search?keywords=qtcreator)). The packages with `i386` architecture are needed on 64 bit systems; otherwise Qt Creator would not find Android devices to deploy to ([see](https://doc.qt.io/qt-5/android-getting-started.html#linux-64-bit)).

    ```
    sudo apt install qtcreator qtcreator-doc libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386
    ```

2. **Make the Android SDK and NDK writable.** Reason: "Make sure to unpack the Android SDK and NDK to a writeable location that Qt Creator can access later. Otherwise, Qt Creator won't be able to use sdkmanager or find all components even if they were installed manually." ([source](https://doc.qt.io/qt-5/android-getting-started.html)).

    Execute the following command, with the username of the user running Qt Creator usually:

    ```
    chown username:username -R /opt/android/sdk/ /opt/android-ndk/
    ```

3. **Install `CMakeLists.txt.user.template` as a starting point.** This file is provided in the repository as a template for the Qt Creator local project settings file and save you most of the steps listed below. To install it, copy it to `CMakeLists.txt.user` before starting Qt Creator:

    ```
    cp CMakeLists.txt.user.template CMakeLists.txt.user
    ```

4. **Configure Qt Creator for your environment.**

    1. Under  "Tools → Options… → Kits → Qt versions", configure the paths of your new Qt installations.

    2. Under "Tools → Options… → Devices → Android", configure the paths to your Android SDK and NDK.

5. **Make sure there is a kit.** Connect your Android device by USB cable and under "Tools → Options → Kits → Kits" make sure there is an auto-generated kit for this device.

6. **Create the project's build configuration.** Open the "Food Rescue App" projects by opening its `CMakeLists.txt`. Then via the left sidebar, go to "Projects → Build & Run" and:

    1. Configure your project for the Qt Creator kit corresponding to your Android device.

    2. Under "Build & Run → [kit name] → Edit build configuration: Release → CMake", set the correct CMake variables needed for the build process, equivalent to the settings made during the command line build process. (TODO: How. Especially since some of the command line variables could only be set as environment variables, not via a `cmake -D` switch.)

7. **Build and deploy to Android.**

    1. In the bottom left of the Qt Creator window, click on the dropdown button to select your build configuration, and select your project's new Android release build configuration.

    2. Before the first deploy, enable `adb` debug mode on the Android device.

    3. Click the large green arrow button to start the build and deployment process. It should first open a window to let you choose your Android device. If not, follow "[Selecting Android Devices](https://doc.qt.io/qtcreator/creator-developing-android.html#selecting-android-devices)".


### Building Kirigami for Android

We could not yet build Kirigami for Android with Qt Creator. Since it's a library that you only need to build once, setting up Qt Creator for this task also makes little sense. You'll be fine with the build instructions for the command line, see above.


### Improving your Qt Creator setup

If you use Qt Creator as your IDE, here are ways to make developing for this (and other) applications pleasant and efficient:

1. **If not on Ubuntu: Adapt your `QML_IMPORT_PATH`.** The `QML_IMPORT_PATH` is needed for Qt Creator's code completion to work. Otherwise, it will complain at QML `import` statements but builds would still succeed. This application already defines `QML_IMPORT_PATH` for all required QML files as found in Ubuntu Linux based distributions, using [this technique](https://stackoverflow.com/a/62202304). If you're not on Ubuntu, you may have to add some directories by defining CMake variable `QML_IMPORT_PATH` according to [these instructions](https://stackoverflow.com/a/62222947).

2. **Install the Android examples.** The following will install relevant Qt examples for Android development, leaving out other examples. Note that for each example, three packages are needed: source files, API docs (used for the help system) and HTML docs (used for the example index in the welcome page etc.). We avoid installing packages `qt5-examples`, `qt5-doc` and `qt5-doc-html` as each of these would bring in documentation and other material from unnecessary examples.

    ```
    sudo apt install qtbase5-examples qtdeclarative5-doc qtdeclarative5-doc-html qtdeclarative5-examples qtquickcontrols2-5-doc qtquickcontrols2-5-doc-html qtquickcontrols2-5-examples qtsensors5-doc qtsensors5-doc-html qtsensors5-examples qtxmlpatterns5-doc qtxmlpatterns5-doc-html qtxmlpatterns5-examples qtconnectivity5-examples qtconnectivity5-doc qtconnectivity5-doc-html qtdatavisualization5-examples qtdatavisualization5-doc qtdatavisualization5-doc-html qtmultimedia5-examples qtmultimedia5-doc qtmultimedia5-doc-html qtsvg5-examples qtsvg5-doc qtsvg5-doc-html qttools5-examples qttools5-doc qttools5-doc-html qtwayland5-examples qtwayland5-doc qtwayland5-doc-html qtxmlpatterns5-examples qtxmlpatterns5-doc qtxmlpatterns5-doc-html
    ```

3. **Adapt the default build path.** You can set it to whatever you want of course, but pretty sure you're not happy with the long default build directory names. It can be adapted under "Tools → Options → Build & Run → Default Build Properties → Default build directory". I like to set mine to:

   ```
   build/%{JS: Util.asciify("%{CurrentKit:FileSystemName}.%{CurrentBuild:Name}")}
   ```


## 6. Release Process

TODO


# 7. Style Guide

## 7.1. Code Style

The guiding idea is to write code that reads almost like natural language. That affects variable and method naming, source code layout and also choice of the logical flow and distributing algorithmic complexity so that one can understand everything while reading through once.

**Specific code style hints for C++:**

TODO

**Specific code style hints for QML:**

* **Visual order.** Order code elements as much as possible in the order they will appear in the user interface (top to bottom, left to right). If that means mixing contained QML types and QML attributes, so be it.


## 7.2. Documentation Style

**Outsource to Stack Exchange.** To keep this README and other documentation short and to avoid mentioning the same instructions in multiple places, publish re-usable Q&A style instructions as answers to suitable questions on [StackOverflow](https://stackoverflow.com/) or if necessary one of its sister sites. And include just the hyperlink into the project documentation. This also lets others profit from your re-usable pieces of knowledge. Stack Exchange is reasonably stable, so it can be assumed that the links will rot slower than this software itself.


## 7.3. Software Design

TODO


# 8. Contribution Guide

TODO


# 9. License and Credits

**Licenses.** This repository exclusively contains material under free software licencses and open content licenses. Unless otherwise noted in a specific file, all files are licensed under the MIT license. A copy of the license text is provided in [LICENSE.md](https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md).


**Credits.** Within the rights granted by the applicable licenses, this repository contains works of the following open source projects, authors or groups, which are hereby credited for their contributions and for holding the copyright to their contributions:

* **[Open Food Facts](https://openfoodfacts.org/).** This project relies heavily on the groundwork done by the open source [Open Food Facts](https://openfoodfacts.org/) project for creating a data commons for food products identified by a GTIN barcode. Actual content from Open Food Facts is included only via the [foodrescue-content](https://github.com/fairdirect/foodrescue-content) repository; see there for licencing details.

* **[IQAndreas/markdown-licenses](https://github.com/IQAndreas/markdown-licenses).** Provides orginal open source licenses in Markdown format. The `LICENSE.md` file uses one of them.

* **[Qt](https://qt.io/) and [KDE Kirigami](https://kde.org/products/kirigami/) developers.** For creating the world's best framework for convergent application development 😊
