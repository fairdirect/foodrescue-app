# Food Rescue App

🍒🍌🥕🥑🍐🍅🍈🍓🥜🌮🥚🍞🍒🍌🥕🥑🍐🍅🍈🍓🥜🌮🍞🍒🍌🥕🥑🍐🍅🍈🍓🥜🍞🍒🍌🥕🥑🍐🍅🍈🍓🍞🍒

&nbsp;

**[1. Overview](#1-overview)**<br/>
**[2. Installation](#2-installation)**<br/>
**[3. Usage](#3-usage)**<br/>
**[4. Repository Layout](#4-repository-layout)**<br/>
**[5. Development Guide](#5-development-guide)**

  * [5.1. Dependencies Overview](#51-dependencies-overview)
  * [5.2. Linux Development Setup](#52-linux-development-setup)
  * [5.3. Linux Build Process](#53-linux-build-process)
  * [5.4. Android Development Setup](#54-android-development-setup)
  * [5.5. Android Build Process](#55-android-build-process)
  * [5.6. Qt Creator Setup](#56-qt-creator-setup)

**[6. Release Guide](#6-release-guide)**<br/>

  * [6.1. Initial Setup](#61-initial-setup)
  * [6.2. All Platforms](#62-all-platforms)
  * [6.3. Google Play](#63-google-play)
  * [6.4. APK on website](#64-apk-on-website)

**[7. Style Guide](#7-style-guide)**

  * [7.1. Code Style](#71-code-style)
  * [7.2. Documentation Style](#72-documentation-style)
  * [7.3. Software Design](#73-software-design)

**[8. Contribution Guide](#8-contribution-guide)**<br/>
**[9. License and Credits](#9-license-and-credits)**

------


# 1. Overview

This repository contains an open source application to help assess if food is still edible. When you scan a food product’s barcode or search for a food category, the application will collect and show whatever it knows about assessing the edibility of this food item. The main innovation is to combine barcode scanning with food rescue information, which makes that information more accessible than through any existing solution.

The application is built with KDE Kirigami, a rather unknown but powerful base technology that makes this a native, cross-platform, desktop/mobile convergent application. See below for the full list of features enabled by this choice.


**Screenshots:** (Click to enlarge.)

<p align="center">
  <a href="doc/readme-screenshot-1.jpg?raw=true"><img src="doc/readme-screenshot-1.jpg?raw=true" width="24%"></a>
  <a href="doc/readme-screenshot-2.jpg?raw=true"><img src="doc/readme-screenshot-2.jpg?raw=true" width="24%"></a>
  <a href="doc/readme-screenshot-3.jpg?raw=true"><img src="doc/readme-screenshot-3.jpg?raw=true" width="24%"></a>
  <a href="doc/readme-screenshot-4.jpg?raw=true"><img src="doc/readme-screenshot-4.jpg?raw=true" width="24%"></a>
</p>


**Online Demo:** An online demo of the Android version of Food Rescue App is [available on appetize.io](https://appetize.io/app/hkw36e77yj8bqra3mufde078ug?device=nexus7&scale=75&orientation=portrait&osVersion=8.1). This gives you a complete, browser based Android emulator with Food Rescue App pre-installed to try it out. Due to the nature of operating an Android device through the browser, not all features are available. Notes:

* **No camera.** The "scan barcode" button only shows a dummy camera view and you cannot scan barcodes.
* **Search for barcodes.** To look up content associated with barcodes, you can however type their numbers directly into the search field. Good examples are: `1000110007387`, `2165741004149`, `2205873003013`.
* **Search for food categories.** The most interesting way to interact with the demo is to look up the content for food categories by entering the categories into auto-complete search field. Type whatever English food category names you can think of; or also names in other languages after changing the application language in the settings.
* **Disable the virtual keyboard.** Since you have a proper keyboard on a desktop computer to type, it helps with screen space to disable the Android on-screen keyboard completely. You can do that after clicking on the keyboard symbol in the bottom right.
* **Avoid landscape mode.** Due to a bug in the appetize.io product, the directions of the arrow keys are switched in landscape mode: <kbd>→</kbd> moves down, <kbd>↓</kbd> moves right etc.. Until that is fixed, better avoid landscape mode, or only navigate with the mouse in there.
* **Avoid Android ≥9.** In this application's online demo, landscape mode does not work at all when you choose Android 9.0 or 10.0.


**Features:**

* **Mobile/desktop convergent.** The application runs from the same codebase and with the same user interface as a native (!) application on both phones, tablets and desktop computers. This is made possible by Qt 5 and, based on that, the [KDE Kirigami](https://kde.org/products/kirigami/) framework. Kirigami is a niche technology right now and not advertised much, but it totally works and allows an efficient "write once, run everywhere" development mode that also reduces software maintenance costs because there is only one codebase.

* **Cross-platform.** Currently, Food Rescue App has been tested under both Android and Ubuntu Linux. But it supports also all other platforms where Qt is available. That includes the [officially supported platforms](https://doc.qt.io/qt-5/supported-platforms.html) Linux, macOS, Windows, Android, iOS and UWP (“Windows Mobile”). In addition, it is possible to use the application under FreeBSD, which is also supported by the Kirigami framework ([see](https://invent.kde.org/frameworks/kirigami/-/blob/master/metainfo.yaml#L5)) and on minor mobile platforms such as [Ubuntu Touch](https://en.wikipedia.org/wiki/Ubuntu_Touch), [Sailfish OS](https://en.wikipedia.org/wiki/Sailfish_OS) and [LineageOS](https://lineageos.org/), all of which are prepared to run Qt applications. To note, the application is a native compiled cross-platform application, *not* using any cross-platform technology built around web technologies (such as Electron) that would rather make it a packaged web application.

* **Scan to check.** To quickly find the required information about a food item, scan its GTIN barcode with the camera of your device.

* **Offline use.** The application obtains all its data from an on-device SQLite3 database, so you can use it without the Internet, whether that means in a supermarket in the basement, on a sailing trip where you caught too much fish, or if you happen to live in a sparsely populated area where Internet access is expensive or unreliable.

* **Multi-lingual.** The application’s user interface and content are available in German and English, and any number of additional languages can be added in the same way. With at least 1000 entries each, the food category names are right now complete enough for real-world use in seven languages (German, English, French, Dutch, Spanish, Italian, Finnish).

* **Keyboard control.** The application can be fully controlled by keyboard shortcuts. That also works in the mobile variant, such as for Android based netbooks.

* **Desktop touch friendly.** As a side effect of convergent application development, the user interface is touch control friendly even in the desktop version. That's useful for the considerable amount of notebook computers with touchscreens.

* **Works on old or slow hardware.** The application is designed to be usable on low-resourced hardware, whether that means entry-level or old mobile devices. This is made possible by relying on compiled C++ code, resulting in native applications on all platforms. The native performance is esp. relevant for the barcode scanner feature. It exceeds that of any barcode scanner in JavaScript, and also that of any barcode scanner in Java, which is otherwise the default choice in an Android application.

* **Compact size.** The application's database is relatively compact, so that it is not (yet) necessary to split it into several databased by world region. As of 2020-08, the current installation size of the database is 27 MiB, containing 448&nbsp;224 food products, 9818 food categories and 674&nbsp;021 assignments of categories to products. [We collected techniques](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=CbJves6WjN7La8VqenFe0zjE) that allow to bring this size down to 6 MiB in the future. Even if in the future all the world's food products with barcodes would be contained in that database, wit these techniques the size would then probably not exceed 40 MiB, which is still very acceptable even for entry-level smartphones.

* **Web application ready.** Food Rescue App can be used over the Internet from within a web browser, using [Qt WebGL Streaming](https://doc.qt.io/qt-5/webgl.html). This is slower than a "normal" web application and only suitable for demonstration purposes. However, [Viridity](https://github.com/evilJazz/viridity/tree/v3) or [other interesting technologies](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=E34d0t1guv-W5DImJF1zldh9) would allow to extend Food Rescue App to also be a native web application in the future.


**Limitations:**

* **Installation size.** On systems without a proper package manager, the full Qt libraries have to be included when distributing the application. This increases the installation size from 400 kiB (on Linux) to 37 MiB (on Android). Something can be done about this issue though, because even when distributing the Qt libraries, they do not have to be that large. It’s just that nobody really cared about the Qt installation size under Android and iOS. I already [discovered techniques](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=dI8VwnzUsz7jXpZFlJJPQUaR) that should reduce that size by at least 75% in a future release.

* **Memory consumption due to QML.** By using KDE Kirigami, the application relies on the Qt QML technology. For Qt 5 this means that the application contains some JavaScript code and a JavaScript virtual machine. This code is not a performance bottleneck: it does not provide the performance of compiled code but is also not used for any performance critical parts such as the database and barcode scanner. However, the more important issue with QML is its excessive main memory consumption.

    At startup, Food Rescue App will have a memory consumption of 77 MiB, of which 53 MiB are program code and shared libraries (called shared memory in `top` because it can possibly be shared with other processes, but in practice rather not). After some usage, Food Rescue App will have a maximum memory consumption of 157 MiB, of which 87 MiB are program code and shared libraries. Compare that with the memory consumption of a Qt Widgets based application of similar complexity (here: `tom-ui`), which will have a memory consumption of 23 MiB, of which 18.5 MiB are program code and shared libraries.

    However, the good news is that this situation will be resolved when Qt 6 is released. Qt 6 will support compiling QML to native C++ code, which should make Qt QML based applications equivalent in memory usage to Qt Widgets based applications.

* **Memory consumption due to Qt.** Applications are supposed to use the UI libraries of the operating system. This is quite memory efficient, as the shared library system means that the code of these libraries is mapped into the virtual memory spaces of all processes accessing them, without duplicating them in the main memory. However, Qt is a cross-platform library made in such a way that it provides its own UI library, implemented down to the level of OpenGL rendering. This duplicates functionality provided by the operating system and can only be shared between other processes also using the Qt libraries. Except under Desktop Linux (where Qt is widespread), Food Rescue App will often be the only Qt based process in the memory. So the memory used by the Qt libraries can be counted as additional memory use compared to an application using the OS libraries. (On the other hand, one could also argue that the problem starts with operating systems using different UI libraries and that a cross-platform UI library like Qt is the right way to do things.)

    The amount of this (unavoidable) additional memory usage of "barebones Qt" is about 18-20 MiB. This has been determined from the amount of Linux shared memory of a Qt 5 widget-based application that does not use any libraries beyond Qt (here: `tom-ui`). Basically look up the process in `top` and find the value in column `SHR`. To be exact, some more would have to be added on top of the 18-20 MiB, to account for the variables associated with the Qt code in shared memory.


**Alternative uses:** Since this is open source software, you are free to create anything else out of this application if you like. Since the application is essentially an offline reader for dynamically collected DocBook content, the closest alternative use would be to just exchange the database and use it as an offline reader for other content. When made generic, such a software could be called a databook reader. [See here](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=-E1SzFIlt-BBqgUOV2aO4FQZ) for more details.


**Documentation:**

* **Project website.** The project's website with introductory information and relevant links is [fairdirect.org/food-rescue-app](https://fairdirect.org/food-rescue-app).

* **Project README.** You're reading the project README right now. It includes all the essential documentation, including a datasheet, installation, usage and build process.

* **Developer knowledge base.** Extensive documentation about planned features, used technologies, frequent tasks and related projects and initiatives is available as a Dynalist document ["Food Rescue App Documentation"](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA). The same content is also available as an exported version under `doc/doc.html` in this repository. But the export is still rough and does not support proper navigation in the document, so at this time the Dynalist live document is preferable.

* **Code documentation.** The project's C++ source files contain in-code documentation that you can compile into full API docs with [Doxygen](https://www.doxygen.nl/).

* **Database documentation.** The database used by Food Rescue App is developed in its own project [Food Rescue Content](https://github.com/fairdirect/foodrescue-content), which comes with its own set of documentation.


# 2. Installation


We provide installation packages only for Android at the moment. For other platforms, you would have to [build the software yourself](#5-development). Details:

* **✅ For Android.** You can install the app directly [from Google Play](https://play.google.com/store/apps/details?id=org.fairdirect.foodrescue) or [download the APK](http://fairdirect.org/downloads/foodrescue.apk) of the latest release. In the future, we also want to publish it in [F-Droid](https://f-droid.org/) and the [KDE Android F-Droid repository](https://community.kde.org/Android/FDroid), which also contains all other Kirigami based Android applications.

* **❎ For iOS.** No installation package available. In the future, we want the app to be available in the Apple App Store.

* **❎ For Linux.** No installation package available. In the future, we want to provide a package for Ubuntu 20.04 LTS and its variants via a PPA package repository.

* **❎ For Windows.** No installation package available. In the future, we want to provide a self-extracting installer.

* **❎ For Mac OS X.** No installation package available. In the future, we want to provide a DMG package.


# 3. Usage

**Basic usage:** The app will show you food rescue information associated with product barcodes or food category names. The most comfortable usage is to click the button with the barcode icon to scan a food packaging barcode with the device camera. If that yields no results, you can also enter a food category into the search field. Auto-complete will help you select from the existing categories. In addition, there's a browsing history feature available via the two buttons with arrow icons. Browsing history is stored until closing the application. All functionality is available in multiple languages, which can be changed in the settings. The selected language will influence how content is displayed and which language is used to auto-complete category names in the search field.

**Tips for scanning barcodes:** (By importance, the important ones first.)

* **Align the lines.** Barcode scanning works only when the barcode lines are either vertical or horizontal on your screen, or slanted up to about 15° from that. When the lines are 45°, no barcodes are recognized due to software limitations.

* **Focus.** Barcodes cannot be recognized from out-of-focus camera images. So when you notice that the barcode lines appear blurred in your camera viewfinder, try the following: (1) Move the barcode further from the lens. Autofocus cameras have a minimum focus distance of 10-15 cm while manual focus webcams have to be adjusted by turning a focus ring and fixed focus webcams are usually configured to focus at 60 cm for a video call setup. (2) Move the barcode centrally into the viewfinder, because that is where an autofocus camera will try to focus on by default. (3) Get more light to shine on the barcode, because the autofocus has issues focusing when contrast is too low.

* **Plain and steady.** Hold the barcode parallel to the camera lens and keep it steady for a few seconds. That is the best way to get a scan. The camera simply needs up to a few seconds to adjust exposure and focus to capture the barcode perfectly. This is a gradual process, so if you change something in the scene too early to "help" the camera, it will just slow down the barcode scanning as the camera has to start its adjustment process again.

* **Lighting.** Good and even lighting is important for fast barcode recognition. Barcode recognition usually works acceptably with usual indoor lighting levels, but can become difficult the smaller the barcodes are.

* **Exposure.** Barcode recognition is very sensitive to overexposure of the barcode area, but not much to underexposure. A dark camera image background leads to overexposure of the barcode's white area, so prefer a lit / light background. Or try moving the barcode closer to the camera so that less background is visible and won't influence the exposure so much.

* **No need to scan straight down.** It does not matter if the barcode plane is not exactly parallel to the camera lens. The barcode will appear slightly distorted in the camera viewfinder, but be detected with the same speed and precision.

* **Multiple barcodes.** In rare cases there can be misreadings if more than one barcode is visible and barcodes overlap partially. Numbers would then not correspond to either barcode. Overlapping barcodes will not happen in live usage, but might when testing with pieces of paper.


**Keyboard combinations:** (TODO: Complete this list. There should be an official list somewhere.)

* **Content browser related.**
    * **Scroll a bit.** Arrow Up / Arrow Down.
    * **Scroll one page.** Page Up / Page Down.

* **Auto-complete related.** It works the same as in a Google Search:
    * **Edit mode.** F2 will always put the cursor back into the autocomplete field, and show the completions (if any).
    * **Next / previous completion.** Arrow Down / Arrow Up.
    * **Choose completion.** Return or Enter.
    * **Close completion box.** Escape.
    * **Close and leave completion box.** Press Escape twice. It will move the keyboard focus to the browser so you can keyboard-scroll there afterwards.

* **Kirigami defaults.**
    * **Page back / forward.** Alt + Arrow Left / Alt + Arrow Right. You can also use the hardware keys "Page Back" and "Page Forward" if you have them. Not found often, but for example some Lenovo ThinkPad models have these above the Arrow Left / Arrow Right keys.
    * **Select all.** Ctrl + A selects all content of the focused element, for example a text field.
    * **Move focus.** Tab moves the keyboard focus to the next element, Shift + Tab moves it to the previous element.
    * **Click on focused element.** The Space bar key is like clicking on the element currently having the keyboard focus. Except for text fields, where you need Return or Enter.
    * **Activate menu item.** Alt + highlighted letter while menu drawer is open.
    * **Close overlay sheet.** There is no default key binding for this. Esc does not work. Some applications bind the "Alt + Left" and "Page Back" keys to this, for example the Kirigami Gallery demo application.
    * **Close the application.** Ctrl + Q.


**Command line options:**

* **`-style`, `-stylesheet`, `-widgetcount`, `-reverse`, `-qmljsdebugger`:** The default command line options available in every Qt application and [documented by Qt](https://doc.qt.io/qt-5/qapplication.html#QApplication).


**Environment variables:**

* **Under Linux: `LANG`, `LANGUAGE`, `LC_ALL`:** Sets or overrides the application's locale using relatively convoluted rules [summarizes here](https://superuser.com/a/392466). Qt automatically completes any language specified as a two-lette language code (like `de`) to a full five-letter language code with country code. For example, `de` is expanded to `de_DE` and `en` to `en_US`.


# 4. Repository Layout

Here is a quick overview of what you'll find where and why.

**General source layout:** We make use of the Ubuntu operating system packages as much as possible to provide dependencies (libraries and header files).

Some dependencies cannot be installed that way, including all cross-compiled libraries for Android etc.. These other dependencies are self-compiled, placed into their own independent directories just like this application itself, all having their own "CMake buildsystem" as they say. Sadly, some exceptions are necessary so that some libraries have to be placed into this application's source tree; see the documentation for the `lib/` folder below.

In all the above cases, dependencies are connected to this application only via the CMake `find_package(…)` mechanism. That's the most compact and cross-platorm compatible way to manage dependencies in CMake.

**In the repository:**

* **📁 `build/`:** Proposed out-of-source location for build process output. Use sub-directories per platform (`desktop`, `android`, `ios` etc.) and per type of build (delease, debug etc.).

* **📁 `doc/`:** Any project documentation besides this main `README.md` and besides the API documentation generated by Doxygen.

* **📁 `install/`:** Proposed out-of-source location for `make install` output. Needed as part of the Android build process to have a location of all files that should make it into the Android APK package. Use sub-directories per platform (`desktop`, `android`, `ios` etc.).

* **📁 `lib/`:** External libraries that contain QML, which necessitates to place them below the repository root during the build process [due to a limitation of `qmlimportscanner`](https://stackoverflow.com/a/62326971), the program that runs to find all QML files that have to be included into the APK package. The libraries are managed as their own Git repositories but have to be placed here for the build to succeed. In our case, you would put Kirigami here.

* **📁 `src/`:** The project's actual source code.

* **📄 `CMakeLists.txt`:**

* **📄 `CMakeLists.txt.user.template`:**

* **📄 `LICENSE.md`:** The main licence file.

* **📄 `README.md`:** This README.

* **📄 `metadata-*`:** Application metadata for various environments. Informs a desktop environment where to put the application into the start menu, what icon to use etc..


# 5. Development Guide

The following chapters provide a setup to build Food Rescue App under Ubuntu Linux 20.04 LTS. The instructions are mostly the same under other Ubuntu flavors and other [Debian (Testing) based Linux distributions](https://en.wikipedia.org/wiki/List_of_Linux_distributions#Debian_%28Testing%29_based).

Do not try to do this setup under earlier versions of Ubuntu Linux, such as Ubuntu 19.10. Kirigami 5.68.0 will require ECM 5.68.0 which will require cmake 3.16 which is not available in the repositories of that distro. Trying to install the cmake package from Ubuntu 20.04 will also not be possible. It is somehow possible to make this setup (I made it once under Ubuntu 19.10), but the time is better invested updating the development system.

If you are setting up your development environment under Windows or Mac OS X, you are so far on your own; you can however learn the required versions of Android SDK, NDK, Qt, KDE ECM and Kirigami from the instructions below.


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

* **Qt 5.14 support.** When trying Qt ≥5.14 for Android with ECM 5.62, you would see `androiddeployqt` fail during the build process with the error message "No target architecture defined in json file". This seems to be due to the same change in Qt that also caused the equivalent issues [#35](https://github.com/LaurentGomila/qt-android-cmake/issues/35) in [qt-android-cmake](https://github.com/LaurentGomila/qt-android-cmake) and [#23306](https://bugreports.qt.io/browse/QTCREATORBUG-23306) in the CMake scripts for Android deployment that come with Qt Creator. It has to be fixed in every set of CMake scripts that are used for Android deployment, and ECM is yet another one of these. It was fixed with ECM [commit c9ebd39](https://invent.kde.org/frameworks/extra-cmake-modules/commit/c9ebd39) – see the commit message there. That commit was on 2020-03-03 and the [Git tag list](https://invent.kde.org/frameworks/extra-cmake-modules/-/tags) shows it landed in 5.68.0.


## 5.2. Linux Development Setup

This assumes you want to use a Linux host for development and build the desktop version.

1. **Install basic development tooling.** Under Ubuntu 20.04 LTS, install with:

     ```
     sudo apt install build-essential cmake checkinstall
     ```

2. **Install Extra CMake Modules (ECM).** Under Ubuntu 20.04 LTS, you can install ECM 5.68.0 with:

    ```
    sudo apt install extra-cmake-modules
    ```

    ECM ≥5.68.0 is required for Qt ≥5.14, for Android NDK ≥19 and for Kirigami 5.68.0 (as installed below). There is no need for an even newer version. But if you encounter that need, or if your distribution does not provide ECM ≥5.68.0, you can install ECM manually as follows:

    ```
    git clone https://invent.kde.org/frameworks/extra-cmake-modules.git
    cd extra-cmake-modules

    # Adapt to the commit of a stable version ≥5.68.0, here 5.72.0. Find the version tag commit hashes on
    # https://invent.kde.org/frameworks/extra-cmake-modules/-/tags
    git checkout ada528dc

    mkdir build && cd build && cmake ..
    make

    # Adapt to the version you checked out, here 5.72.0.
    sudo checkinstall --pkgname extra-cmake-modules --pkgversion 5.72.0 make install
    ```

3. **Install Qt 5.12.0 or up to 5.13.2.** Qt 5.12.0 or higher [is required](https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/CMakeLists.txt#L8) by KDE Kirigami 5.68.0. Under Ubuntu this is installed automatically as a [dependency of Kirigami](https://launchpad.net/ubuntu/focal/amd64/libkf5kirigami2-5/5.68.0-0ubuntu2) (see below). Ubuntu 20.04 LTS provides Qt 5.12.5 while Ubuntu 19.10 provides Qt 5.12.4 ([see](https://reposcope.com/package/qt5-default)).

    In principle, you could also install Qt 5.13 or higher. Qt 5.13 or higher for desktop Linux applications as installed here works fine out of the box. However, it is advisable to keep the Qt versions for desktop Linux and Android the same to avoid surprises. And when installing Qt 5.13 or higher for Android, additional steps will be needed, as detailed in chapter [5.4. Android Development Setup](#54-android-development-setup) below.

4. **Install KDE Kirigami 5.68.0 or higher.** [As provided](https://launchpad.net/ubuntu/focal/amd64/kirigami2-dev) under Ubuntu 20.04 LTS and installed there with:

    ```
    sudo apt install kirigami2-dev libkf5kirigami2-doc
    ```

    Under other distributions, you may have to install Kirigami 5.68.0 manually; in that case choose the corresponding commit `f47bf906` ([source](https://invent.kde.org/frameworks/kirigami/-/tags)). Avoiding a higher version can be necessary as that higher version may require newer Qt libraries than provided by your system.

    Note that KDE Kirigami is a lightweight library independent of the KDE Plasma desktop environment – it has no dependencies beyond Qt, and you don't need KDE Plasma installed to use it or develop for it.

5. **Install Qt5 development utilities.** Qt comes with some development tools. We'll need `xmlpatterns`, the XSLT processor utility, as it helps to test DocBook-to-HTML transformations developed for this software. We'll also need `linguist`, the Qt user interface translation utility. Install them with:

    ```
    sudo apt install qtxmlpatterns5-dev-tools qttools5-dev-tools
    ```

6. **Make Qt5 your default Qt version.** If you have installed both Qt4 and Qt5 on your system, only one of them will be the default for same-named Qt binaries that you'll need during the development process. Build tools are not affected by this, as they will always call Qt binaries with a `-qt=5` argument to make sure they use Qt4 tools. But when using Qt binaries manually, not having Qt 5 as the default version is annoying. On Ubuntu `sudo apt install qt5-default` will make Qt5 the default, while on other systems you might have to deal with `qtchooser` ([details](https://stackoverflow.com/a/39742962)).

7. **Install [ZXing-C++](https://github.com/nu-book/zxing-cpp).** This has to be compiled from source because we rely on a newer version than Ubuntu 20.04 [package zxing-cpp](https://launchpad.net/ubuntu/+source/zxing-cpp) (which anyway seems only available as a proposed package there right now). Commit 57c4a89 from 2020-06-25 is the last version that has been tested, and also the minimum necessary version (as it provides CMake package versioning that we rely on).

    We do a system-wide installation to keep `cmake` calls simple for desktop development. But we also use `checkinstall` (`sudo apt install checkinstall`) to create and install a simple Ubuntu package. That makes it much easier to uninstall all installed ZXing files again when necessary (`sudo apt remove zxing-cpp`).

    ```
    cd /some/out-of-source/path/
    git clone https://github.com/nu-book/zxing-cpp.git
    cd zxing-cpp
    git checkout 57c4a89

    mkdir -p build/linux_amd64 && cd build/linux_amd64
    cmake ../..
    make
    sudo checkinstall --pkgname zxing-cpp --pkgversion "1.0.8+57c4a89" --nodoc make install
    sudo ldconfig
    ```

    TODO: In the above instructions, do a shallow clone that contains the history only starting from the relevant commit 57c4a89. Not sure if there is any good solution for that, though ([see](https://stackoverflow.com/q/31278902)).

8. **Install the remaining Qt header files (optional).** To be able to access all components of Qt in your code without having to install more packages on demand, you can install all the Qt header files already:

    ```
    sudo apt install \
      libqt5gamepad5-dev libqt5opengl5-dev libqt5sensors5-dev libqt5serialport5-dev \
      libqt5svg5-dev libqt5websockets5-dev libqt5x11extras5-dev libqt5xmlpatterns5-dev \
      qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev qtdeclarative5-dev-tools \
      qtlocation5-dev qtpositioning5-dev qtquickcontrols2-5-dev qtscript5-dev \
      qttools5-dev qttools5-dev-tools qtwayland5-dev-tools qtxmlpatterns5-dev-tools
    ```

9. **Install the translation tooling.**

    ```
    sudo apt install omegat
    ```

10. **Install the database.** The application relies on a database that is the build output of [project `foodrescue-content`](https://github.com/fairdirect/foodrescue-content). During development we'll want to run the application without installing it every time. so we'll have to install the database manually to let the application find it. Instructions:

    1. Select the directory where to install the database. This depends on your operating system. Select a suitable location with path type `AppLocalDataLocation` from [Qt's list of standard locations](https://doc.qt.io/qt-5/qstandardpaths.html#StandardLocation-enum). For Linux, this would be `/usr/local/share/foodrescue/` or `~/.local/share/foodrescue/`.

    2. Download the latest available version of the database from [foodrescue-content releases](https://github.com/fairdirect/foodrescue-content/releases) and place it into the database directory. (If you want, you can of course also follow the [foodrescue-content README](https://github.com/fairdirect/foodrescue-content#readme) to build the database yourself.)

    3. Unpack the downloaded database: `unzip foodrescue-content.sqlite3.zip`. You should now have a file `foodrescue-content.sqlite3` that Food Rescue App will find at startup.


## 5.3. Linux Build Process

You can also build the Linux desktop application from inside Qt Creator. See chapter [5.6. Qt Creator Setup](#56-qt-creator-setup).

1. **Get the application source code** by cloning its repository:

    ```
    git clone git@github.com:fairdirect/foodrescue-app.git
    ```

    Or if working on a host where you did not set up your SSH key you use for Github:

    ```
    git clone git://github.com/fairdirect/foodrescue-app
    ```

2. **Build the translation files.** (Context: [process to update translation files](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=b4LNy6sLKwEfTkXtMVXP9NlP).)

    ```
    cd foodrescue-app
    lrelease src/i18n/foodrescue_*.ts
    ```

3. **Build the application.**

    ```
    cd foodrescue-app
    mkdir -p build/linux_amd64_cli && cd build/linux_amd64_cli
    cmake ../..
    cmake --build .

    # Optional: if you don't want to run the binary in place.
    make install
    ```

    As an alternative to `cmake --build .`, you can also simply run `make`, because CMake is a tool that generates GNU Make makefiles.

4. **Run the application.** To run the application in place without installing it, you'd do:

    ```
    ./bin/foodrescue
    ```

    If you have done the `make install` step, you can also start the application from your desktop environment's start menu, or you can start it with:

    ```
    foodrescue
    ```


## 5.4. Android Development Setup

This assumes you want to use a Linux host for development and build the Android version. This section will being you up to the point where you an actually build the application and start developing it further.

The commands below are shown for the armeabi-v7a Android ABI, but you can adapt them to your targeted ABI easily. This has been tested for armeabi-v7a, arm64-v8a and x86 already. One clone of the Git repository can be used to build for all Android ABIs by following these instructions multiple times but choosing separate build directories (`build/android_armv7`, `install/android_arm64_v8a` etc.) and install directories (`install/android_armv7`, `install/android_arm64_v8a` etc.).

1. **Make the development setup for the desktop version.** Follow all steps from chapter "[5.2. Desktop Version Development Setup](#52-desktop-version-development-setup)". Ideally also make sure you can build and execute a desktop version; you can also do that during Android development to quickly test code that is not specific to Android. (If you want to build for Android only, you don't have to follow the steps to install Qt or Kirigami for the desktop version. But then you can't test with the desktop version either, obviously.)

2. **Create an Android installation directory.** Different from development of a desktop software, all components of the Android software must be installed. This is required for building an Android APK package with `make create-apk`. Note that Food Rescue App and all its custom libraries must be installed into the *same* directory for the Android APK building to succeed. We'll create an installation directory inside the repository directory `foodrescue-app` (which you already have from the desktop setup):

    ```
    cd foodrescue-app
    mkdir -p install/android_armv7
    ```

3. **Install OpenJDK 8.** This is a dependency of the Android stack and of Qt Creator. Later versions will not work – [see](https://doc.qt.io/qtcreator/creator-developing-android.html#requirements). And when not doing the `update-alternatives` step, command line utilities that do not inherit the Qt Creator Java path (such as `sdkmanager` when started manually) will fail to run.

    ```
    sudo apt install openjdk-8-jdk
    sudo update-alternatives --config java
    ```

4. **Install `sdk-tools-linux-4333796.zip`.** Do not install the newer replacement for this, called "commandlinetools 1.0" as provided on the [Android Studio download page](https://developer.android.com/studio) ([reasons](https://stackoverflow.com/a/62073804)).

    Download and unpack the package to the place that will later also host the Android SDK:

    ```
    mkdir -p /opt/android-sdk/ && cd /opt/android-sdk/
    wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
    unzip sdk-tools-linux-4333796.zip
    ```

    Make the `sdkmanager` command accessible system-wide:

    ```
    sudo ln -s /opt/android-sdk/tools/bin/sdkmanager /usr/local/bin/
    ```

5. **Install the Android stack.** Use the now-installed `sdkmanager` to download the SDK packages required for Android development ([source](https://doc.qt.io/qtcreator/creator-developing-android.html#requirements)). It starts with batch-accepting all the licences so we don't have to bother with that stuff ever again later ([see](https://stackoverflow.com/a/4682241)).

    ```
    yes | sdkmanager --licenses
    sdkmanager --install "platform-tools" "platforms;android-29" "build-tools;28.0.2" "ndk;18.1.5063045"
    ```

    Explanations:

    We choose an Android SDK platform (like `platforms;android-29`) that provides at least the API level of your device. The API level supported by your Android testing device can be found [here](https://developer.android.com/studio/releases/platforms). The Qt documentation tells to choose API level 28 for the build SDK of a Qt 5.12.0 - 5.13.1 application ([see](https://doc.qt.io/qtcreator/creator-deploying-android.html#selecting-api-level)). However it works fine with API level 29 here, probably because we use CMake here and not Qt's default build system qmake. Also, choosing a newer SDK here than your targeted devices provide is no problem, as APK packages are configured via `AndroidManifect.xml` to accept a minimum API level of 16 and target API level 29 for installation.

    The version of the build tools has to correspond to the version of the Android SDK platform, but will not be the same version. For example in the versions chosen below, indeed, build tools 28.0.2 are required to go together with Android platform SDK 29. The requirements can be found on [this page](https://developer.android.com/studio/releases/platforms).

    According to the [official Qt Creator installation instructions](https://doc.qt.io/qtcreator/creator-developing-android.html#setting-up-the-development-environment), for Qt 5.12.0 to 5.12.5 (which we use here), the correct versions of Android stack packages are installed with the commands used above. Except, we stick with Android NDK 18 due to an open issue (TODO: link) in KDE's `extra-cmake-modules` with finding the C++ standard library when using Android NDK ≥19.

6. **Install Qt for Android.** Needed because the Ubuntu repositories contain only the desktop variant "Qt 5.12.5 (GCC 5.3.1 … 64 bit)". For Android, we need a variant compiled for ARMv7 and / or ARMv8 architecture instead, and / or even a variant for x86 Android if you intend the application to be used on Android emulators. The below is the most comfortable way to install Qt for Android; for other options, [see here](https://stackoverflow.com/a/62090264).

    1. **Install [`aqtinstall`](https://github.com/miurahr/aqtinstall/).** This is an unofficial installer to install any platform version of Qt on any platform. This is needed because the version of Qt provided in the Ubuntu repositories does not provide the Qt Maintenance Tool that could be used as an alternative.

        ```
        sudo apt install python3-pip
        pip3 install aqtinstall
        ```

    2. **Install Qt for Android.** Use `aqtinstall` to install Qt 5.12.5 for Android.

        ```
        mkdir /opt/qt/
        aqt install --outputdir /opt/qt/ 5.12.5 linux android android_armv7
        aqt install --outputdir /opt/qt/ 5.12.5 linux android android_arm64_v8a

        # Optionally, if you also want to compile for the "minor" Android architectures:
        # (android_x86_64 may not be available for some older Qt versions)
        aqt install --outputdir /opt/qt/ 5.12.5 linux android android_x86
        aqt install --outputdir /opt/qt/ 5.12.5 linux android android_x86_64
        ```

        Explanations: This is the version contained in Ubuntu 20.04 LTS, matching the version you use for desktop development. Matching versions exactly is not strictly necessary, but avoids surprises and keeping two sets of documentation at hand. You can also install Qt 5.13 for Android or higher, but will need additional steps: for Qt 5.13.x or higher, you have to update your `extra-cmake-modules` package manually to 5.68.0 (see chapter [5.1. Version Compatibility Matrix](#51-version-compatibility-matrix)); and for Qt 5.14 or higher additionally you have to [adapt the Android Manifest file](https://stackoverflow.com/a/62108461) of this application. For Qt 5.15, additional steps may be necessary as that has not been tested yet. The next version after Qt 5.15 will probably be Qt 6, to which Kirigami and this application would have to be ported first.

7. **Install Kirigami for Android.** We want to cross-compile an application for Android that depends on Kirigami. Ubuntu repositories do not provide Kirigami built for Android, so we have to do that ourselves. Instructions are mostly [from here](https://community.kde.org/Marble/AndroidCompiling#Setting_up_Kirigami). Note that for desktop builds, we use Kirigami from system packages instead.

    1. Clone the repository inside sub-directory `lib/` of your Food Rescue App project source tree. This is necessary [due to a limitation of the build process](https://stackoverflow.com/a/62326971).

        ```
        cd lib
        git clone https://invent.kde.org/frameworks/kirigami.git
        ```

    2. To get Kirigami 5.68.0, the same version as installed for desktop appliction development under Ubuntu 20.04, choose the corresponding commit `f47bf906` ([source](https://invent.kde.org/frameworks/kirigami/-/tags)):

        ```
        cd kirigami
        git checkout f47bf906
        ```

    3. Run CMake with the environment variables it requires. For the explanation of the variables, see the documentation for the foodrescue-app CMake run in [5.5. Android Build Process](#55-android-build-process).

        ```
        # Adapt to your Android architecture. We use the aqtinstall architecture names here
        # by convention: android_armv7, android_arm64_v8a, android_x86, android_x86_64
        mkdir -p build/android_armv7 && cd build/android_armv7

        export ANDROID_SDK_ROOT=/opt/android-sdk
        export ANDROID_NDK=/opt/android-sdk/ndk/18.1.5063045
        export ANDROID_ARCH_ABI=armeabi-v7a

        cmake ../.. \
          -DCMAKE_SYSROOT=/opt/android-sdk/ndk/18.1.5063045/platforms/android-21/arch-arm \
          -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
          -DCMAKE_PREFIX_PATH=/opt/qt/5.12.5/android_armv7 \
          -DCMAKE_INSTALL_PREFIX=$(readlink -f ../../../../install/android_armv7)
        ```

    4. Build and install:

        ```
        make
        make install
        ```

8. **Build [ZXing-C++](https://github.com/nu-book/zxing-cpp) for Android.** For Android we obviously cannot do a system-wide installation as this build is not meant for the development host system (and not even executable there). We use the same ZXing repository already cloned while doing the desktop development setup, in the same commit version.

    1. **Enter the repository.**

        ```
        cd /path-to-your/zxing-cpp/
        ```

    2. **Configure the build.** Explanations of the variables:

        * **`BUILD_…`**. Setting the CMake variables `BUILD_…=OFF` prevents building the ZXing-C++ examples, which would fail in step "Linking CXX executable ZXingWriter" with error message "ZXingWriter.cpp.o: requires unsupported dynamic reloc R_ARM_REL32". We don't need these examples for Android, and they are probably not made for Android anyway.

        * *(For all other variables, see the documentation for the foodrescue-app CMake run in [5.5. Android Build Process](#55-android-build-process).)*

        ```
        # Adapt to your Android architecture. We use the aqtinstall architecture names here
        # by convention: android_armv7, android_arm64_v8a, android_x86, android_x86_64
        mkdir -p build/android_armv7 && cd build/android_armv7

        export ANDROID_SDK_ROOT=/opt/android-sdk
        export ANDROID_NDK=/opt/android-sdk/ndk/18.1.5063045
        export ANDROID_ARCH_ABI=armeabi-v7a

        cmake ../.. \
          -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
          -DANDROID_SDK_BUILD_TOOLS_REVISION=28.0.2 \
          -DBUILD_EXAMPLES=OFF \
          -DBUILD_BLACKBOX_TESTS=OFF \
          -DCMAKE_INSTALL_PREFIX=$(readlink -f ../../../foodrescue-app/install/android_armv7)
        ```

    3. **Build and install.**

        ```
        make
        make install
        ```

9. **Install Breeze icons.** Used for the icons packaged into the Android APK. This is not strictly necessary as the build system will [clone the Breeze repository](https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/KF5Kirigami2Macros.cmake#L63)
if it's not found. However, it would clone it into the build directory, and that would happen again whenever clearing the build directory, leading to slow builds.

    1. **Clone the breeze-icons repository.** Sadly you cannot use the Ubuntu-supplied package of Breeze icons (yet) because the build system expects a different folder structure inside. We do a shallow clone of only the last commit's state (`--depth 1`) as that is all we need.

        ```
        cd foodrescue-app/lib
        git clone --depth 1 https://invent.kde.org/frameworks/breeze-icons.git
        ```

        The build system will find the icons in `./lib/breeze-icons` inside the Food Rescue App repository, without further configuration being necessary.

    2. **Configure Qt desktop applications to use Breeze icons.** When developing for Android, compiling and testing changes on the desktop application first is a good way to speed up development. In order to look as much as possible like the Android UI, you want your Qt desktop applications to also use the Breeze icons that get packaged into the Android package.

        This is not guaranteed: Breeze is the default icon theme in KDE Plasma, but if you don't use KDE Plasma then another tool could have selected a different icon theme. And when starting, any Kirigami application like Food Rescue App will simply pick up the Qt icon theme in use.

        So first make sure you have the Breeze icon theme installed:

        ```
        sudo apt install breeze-icon-theme
        ```

        Then make it the default. The places to change the icon theme are as follows:

        * **If you use Lubuntu (LXQt):** In `lxqt-config-appearance`, select "Icons Theme → Breeze".
        * **If you use KDE:** Breeze is the default icon theme, but maybe you changed it before. There is a nice command line way to change it back: `lookandfeeltool -a org.kde.breeze.desktop`.
        * **If you use another desktop environment:** Change the icon theme in the ways your desktop environment wants it to be done. Qt applications should pick up this change.
        * **If nothing else works:** Install the Qt5 Configuration Tool (`sudo apt install qt5ct`) and in tab "Icon Theme" select "Breeze".

10. **Install the database.** Since we installed the food rescue database in the desktop development setup already, we only have to symlink it now into the `src/android/assets/` directory. That will cause it to be included as a file when `make create-apk` creates the Android APK package later. And we'll not have yet another version of the database to keep up to date.

    ```
    mkdir src/android/assets/
    ln -s /usr/local/foodrescue/foodrescue-content.sqlite3 src/android/assets/
    ```

    TODO: Include the directory `src/android/assets/` into the repo, then remove the step above to create it.


11. **Adapt the makefile.** Due to open issues with the build process, right now you have to adapt `src/CMakeLists.txt` to your system. In `set(foodrescue_EXTRA_LIBS …)` adapt the path to `libQt5Concurrent.so` for your system. (TODO: This is bad because it ties the application source code to one specific Android ABI, making cross-compiling for different architectures uncomfortable.)


## 5.5. Android Build Process

With the following instructions, you can create an Android APK package, install it to an Android device and run Food Rescue App there. As detailed in section [5.4. Android Development Setup](#54-android-development-setup), the commands below are shown for the armeabi-v7a Android ABI, but you can adapt them to your targeted ABI easily.

1. **Enter into the repository directory.**

    ```
    cd foodrescue-app
    ```

2. **Build the translation files.** (Context: [process to update translation files](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=b4LNy6sLKwEfTkXtMVXP9NlP).)

    ```
    cd foodrescue-app
    lrelease src/i18n/foodrescue_*.ts
    ```

3. **Run CMake with the environment variables it requires.** All paths should be given as absolute paths; it may work with relative paths in some cases, but has lead to so many issues time and again that it's not worth trying. Better just use `$(readlink -f …)` to convert a relative path to an absolute one at runtime. The variables and how to adapt them to your system if needed, in order of appearance:

    * **`ANDROID_SDK_ROOT`.** TODO: Document.

    * **`ANDROID_NDK`.** TODO: Document.

    * **`ANDROID_ARCH_ABI`:** Adapt to the ABI ("application binary interface") of the targeted Android devices. The [available values](https://developer.android.com/ndk/guides/abis) are: `armeabi-v7a` (compatible with more or less all physical Android devices), `arm64-v8a` (newer physical Android devices), `x86` (Android emulators running on PCs, using 32 bit, including [appetize.io](https://appetize.io/)), `x86_64` (Android emulators running on PCs, using 64 bit).

    * **`QTANDROID_EXPORTED_TARGET`.** A name component that will appear in Makefile targets to create the Android APK package define by a corresponding variable via `${ANDROID_APK_DIR}/AndroidManifest.xml`. Since we will only run `make && make install` later this name can be anything as it's not used directly, but it has to be define for CMake to not complain.

    * **`ANDROID_APK_DIR`.** A path to the directory in your source tree that contains `AndroidManifest.xml` and also any other files that you want included into the Android APK package. Especially, files placed into an `assets/` sub-directory in here will be available in the Android app's [`assets/` directory](https://developer.android.com/guide/topics/resources/providing-resources#OriginalFiles). Symlinks will be de-referenced and included as the files they point to.

        Placing your `AndroidManifest.xml` here is required in ECM's [`Android.cmake` toolchain l. 211](https://invent.kde.org/frameworks/extra-cmake-modules/-/blob/master/toolchain/Android.cmake#L211). If this is not set correctly, ECM will use Qt's default manifest template, causing your app package to be named `org.qtproject.example.appname`, the app icons to be missing etc.. While you can use a path relative to the current directory here, it is better to use an absolute path because only that will give an error instead of silently using Qt's default manifest ([see](https://invent.kde.org/frameworks/extra-cmake-modules/-/blob/13a1161/toolchain/Android.cmake#L200)).

    * **`CMAKE_SYSROOT`.** Defaults to `/opt/android-sdk/ndk/18.1.5063045/platforms/android-21/arch-arm` and thus not necessary when compiling for ARM-based Android. However, when compiling for Android for the `x86` platform, you have to set this to `/opt/android-sdk/ndk/18.1.5063045/platforms/android-21/arch-x86`.

    * **`CMAKE_TOOLCHAIN_FILE`.** If you installed ECM manually, adapt this accordingly.

    * **`ECM_ADDITIONAL_FIND_ROOT_PATH`.** TODO: Document.

    * **`CMAKE_PREFIX_PATH`.** TODO: Document.

    * **`ANDROID_SDK_BUILD_TOOLS_REVISION`.** TODO: Document.

    * **`CMAKE_INSTALL_PREFIX`.** Adapt the value to the installation directory chosen at the start of section [5.4. Android Development Setup](#54-android-development-setup). The directory must be the same for the installation of ZXing, Kirigami and this application. For Food Rescue App it must be given as an absolute path because the APK creation step after the compilation will fail otherwise. For other builds you can use relative paths but better always use `readlink -f` to automatically translate a relative to an absolute path.

    * **`KF5Kirigami2_DIR`.** An absolute path to a directory with the `KF5Kirigami2Config.cmake` file that defines the Kirigami CMake package. It is located in a sub-directory of the installation directory chosen above. CMake configuration with a relative path will fail at least with CMake 3.15.4 or newer. About creating the absolute path with `readlink -f` see on `CMAKE_INSTALL_PREFIX`.

    * **`ZXing_DIR`.** An absolute path to a directory with the `ZXingConfig.cmake` file that defines the ZXing CMake package. It is located in a sub-directory of the installation directory chosen above. About the absolute path see on `CMAKE_INSTALL_PREFIX`.

    * **`CMAKE_BUILD_TYPE`.** Controls the build type. Values include `Debug` (the default), `Release` and some more. See also [CMake manual: `CMAKE_BUILD_TYPE`](https://cmake.org/cmake/help/v3.0/variable/CMAKE_BUILD_TYPE.html).

    * **`CMAKE_ANDROID_ASSETS_DIRECTORIES`.** Optional. Points to directories that will be also be included into the Android `assets/` folder of the Android APK package. Files from here will not be found in the installation directory (`CMAKE_INSTALL_PREFIX`), just in the APK package. You do not need to mention `${ANDROID_APK_DIR}/assets/` here, as that is automatically included into the APK's assets directory.

    The code to run CMake (after you adapted the variables as explained above):

    ```
    # Adapt to your Android architecture. We use the aqtinstall architecture names here
    # by convention: android_armv7, android_arm64_v8a, android_x86, android_x86_64
    mkdir -p build/android_armv7 && cd build/android_armv7

    export ANDROID_SDK_ROOT=/opt/android-sdk
    export ANDROID_NDK=/opt/android-sdk/ndk/18.1.5063045
    export ANDROID_ARCH_ABI=armeabi-v7a

    cmake ../.. \
      -DQTANDROID_EXPORTED_TARGET=foodrescue \
      -DANDROID_APK_DIR=$(readlink -f ../../src/android) \
      -DCMAKE_SYSROOT=/opt/android-sdk/ndk/18.1.5063045/platforms/android-21/arch-arm \
      -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
      -DECM_ADDITIONAL_FIND_ROOT_PATH=/opt/qt/5.12.5/android_armv7 \
      -DCMAKE_PREFIX_PATH=/opt/qt/5.12.5/android_armv7 \
      -DANDROID_SDK_BUILD_TOOLS_REVISION=28.0.2 \
      -DCMAKE_INSTALL_PREFIX=$(readlink -f ../../install/android) \
      -DKF5Kirigami2_DIR=$(readlink -f ../../install/android/lib/cmake/KF5Kirigami2) \
      -DZXing_DIR=$(readlink -f ../../install/android/lib/cmake/ZXing)
      -DCMAKE_BUILD_TYPE=Debug
    ```

4. **Build the application.** Note that `make install` is necessary before every `make create-apk` as otherwise newly added files like icons would not land in the Android APK package. Only the files found in `${CMAKE_INSTALL_PREFIX}` at the time when `make create-apk` runs will make it to the APK package! (TODO: This seems to be a bug in the build dependencies, we should try to get it fixed.)

    ```
    make
    make install
    make create-apk
    ```

    You can ignore all the following error messages during the `make create-apk` step; they do not lead to any failures at runtime. (TODO: Investigate and fix the cause of these error messages.)

    ```
    could not find libm.so in
      …/foodrescue-app/build/…/bin
      …/foodrescue-app/install/android_armv7/lib/
      /opt/qt/5.12.5/android_armv7
    could not find libc++_shared.so in [… as above]
    could not find libdl.so in [… as above]
    could not find libc.so in [… as above]

    readelf: Error: '/opt/qt/5.12.5/android_armv7/lib/' is not an ordinary file

    Warning: QML import could not be resolved in any of the import paths: local
    Warning: QML import could not be resolved in any of the import paths: org.kde.kirigami
    Warning: QML import could not be resolved in any of the import paths: org.kde.kirigami.private
    Warning: QML import could not be resolved in any of the import paths: QtQuick.Controls.…
    Warning: QML import could not be resolved in any of the import paths: Qt.test.qtestroot
    ```

5. **Install the application to your Android device.** First enable `adb` debug mode on your Android device, pair it with `adb` on the computer, and then execute:

    ```
    make install-apk-foodrescue
    ```

    This command might not work due to an unresolved issue in ECM about naming the APK file. In that case, you can run the following command to install the APK:

    ```
    adb install -r ./foodrescue_build_apk/build/outputs/apk/debug/foodrescue_build_apk-debug.apk
    ```

    Both commands will first remove a previous version of the app from the device if necessary, but without removing application data or granted permissions. If you rather want to do a completely clean install (for example because you want to force using a new version of the database that is bundled into the APK package), then rather use do this:

    ```
    adb uninstall org.fairdirect.foodrescue
    adb install ./foodrescue_build_apk/build/outputs/apk/debug/foodrescue_build_apk-debug.apk
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


# 6. Release Guide

The default build type is "Debug". To create a release build that is ready for packaging and publishing, follow the process below.


## 6.1. Initial Setup

1. **Select the Android ABIs to support.** You must support both **armeabi-v7a and arm64-v8a** for publishing to Google Play ([see](https://stackoverflow.com/a/53413715)), everything else is optional. Some details about each ABI:

    * **armeabi-v7a.** This is the older default processor architecture of Android devices. Processors supporting arm64-v8a can also run software made for armeabi-v7a but it will run slower, not utilizing the full capabilities of the CPU ([see](https://stackoverflow.com/a/33230181)). Still, for testing or for publishing outside Google Play, a single APK made for `armeabi-v7a` is enough.

    * **arm64-v8a.** The newer, 64 bit version of the older, 32 bit armeabi-v7a architecture. Now forming the new default architecture of Android devices. arm64-v8a and armeabi-v7a together account for 98% of all Android devices in use ([see](https://android.stackexchange.com/a/202022)), so everything else is indeed optional.

    * **x86.** This is just the normal, 32 bit Intel PC architecture. Supporting the x86 and x86_64 ABIs is relevant for Android emulators, including when you intend to use the [appetize.io](https://appetize.io/) service for web-base demos of Android apps.

        Physical Android devices do not use this architecture, except for Chromebooks ([see](https://android.stackexchange.com/a/202022)). Most Chromebooks still use the `x86` and `x86_64` processor architecture and only some use ARM based processors. However, since Chromebooks can also run Linux desktop applications ([see](https://en.wikipedia.org/wiki/Chromebook#Integration_with_Linux)), that seems to be a better route for this application to support them, given that they are more like a notebook than like a typical Android phone or tablet and given that Food Rescue App is available as a native Linux application as well.

    * **x86_64.** The modern 64 bit variant of the Intel PC architecture. For publishing on Google Play, you cannot support only x86 without also supporting x86_64 ([see](https://stackoverflow.com/a/57660992)). So you can either support just armeabi-v7a and arm64-v8a, or all four ABIs.

2. **Set up Google Play Console.** Use any Google account to register on [Google Play Console](https://play.google.com/apps/publish/), the place for publishing Android apps on Google Play. Then create your app in Google Play Console, and do the necessary steps there to be able to upload your first release. Be sure to disable "Google Play App Signing" for your app, as that excludes uploading the locally signed apps that are generated by our build process.

3. **Configure package signing.** It is not possible to use [app signing by Google Play](https://support.google.com/googleplay/android-developer/answer/7384423). That would in theory enable to upload an unsigned AAB file and let Google sign it. But the build process prevents creating unsigned APKs in release mode, as all unsigned builds are always created as debug builds, and these are rejected by Google Play. This is true even when passing `-DCMAKE_BUILD_TYPE=Release` to `cmake`. It can be considered a bug in `androiddeployqt` ([details](https://stackoverflow.com/a/28509035)).

    To set up local app signing, you have to create a keystore file with a signing keypair in Qt Creator. Choose "Projects → (any Android kit) → Build → Build Steps → Build Android APK", click on "Details", then "Keystore: … Create..." and fill in the form. Be sure to remember the location and password of your keystore file and the alias name of your signing key inside it. For full documentation, [see here](https://doc.qt.io/qtcreator/creator-deploying-android.html#signing-android-packages).

    TODO: Find out and document how to create the keystore from the command line instead of relying on Qt creator ([see](https://developer.android.com/training/articles/keystore)).


## 6.2. All Platforms

1. **Update the version.** Updating the version defines the current state as the version number you enter. You have to adapt:

    * In `CMakeLists.txt`: line `project(foodrescue-app VERSION …)`. This version string should only have two components, such as "0.2".
    * In `src/qml/AboutPage.qml`: line `"version": "0.2"`. This version string should only have two components.
    * In `src/android/AndroidManifest.xml`: line `<manifest … android:versionName="0.2" android:versionCode="200" …>`. As per our convention documented there, this version string has three components, the last of which is the "packaging version" that is omitted in the `CMakeLists.txt` version string. It is needed for example to disambiguate [multiple APKs](https://developer.android.com/google/play/publishing/multiple-apks) uploaded for the same release.


## 6.3. Google Play

This is the process to update the application on Google Play. It does not describe the initial setup to be able to upload the application for the first time. For that, [see here](https://support.google.com/googleplay/android-developer/answer/113469).

1. **Create a release build APK for ABI armeabi-v7a.** This can be done on your usual development host. Follow the usual instructions to build the application, just with the following changes:

    * Use a different build directory, such as `build/Android.ConsoleKit.Release`.
    * Use `CMAKE_BUILD_TYPE=Release`. (TODO: Change this to the `RelMinSize` or similar value to create a minimum size release package.)
    * Instead of `make create-apk`, run:

        ```
        make create-apk ARGS="--sign $(readlink -f ../path/to/your/android_release.keystore) foodrescue --storepass your-keystore-password"
        ```

        This is documented in the KDE ECM [AndroidToolchain help page](https://api.kde.org/ecm/toolchain/Android.html#deploying-qt-applications) and in the output of `/opt/qt/5.12.5/android_armv7/bin/androiddeployqt --help`.

2. **Increment the Android version code by one.** Each APK uploaded to Google Play needs its own unique version code, including the separate builds for armeabi-v7a and arm64-v8a that we create in this process ([source](https://stackoverflow.com/a/56361240)). Increment only by one, which affects only the packaging version according to our own conventions used for the Android version code.

3. **Create a release build APK for ABI arm64-v8a.** This is currently done on a build server ([instructions](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=YRxrPujPWlxmLBEuMtPGf1GA)). You can also do it on your development system by having separate build and installation directories for each ABI version.

4. **Create release build APKs for ABIs x86 and x86_64. (optional)** This is currently done on a build server ([instructions](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=ZMF-ImrwTwDVxcMvGoEae6yH)). You can also do it on your development system by having separate build and installation directories for each ABI version.

5. **Log in to [Google Play Console](https://play.google.com/apps/publish/).**

6. **Upload the APKs to Google Play.** You have to upload *all* the APKs generated above. Google Play will take care to choose the correct one for each device wanting to download one.

7. **Update the screenshots.** If there were significant changes to the user interface, run the application under Android and create screenshots for uploading to Google Play. For that, execute something like this:

    ```
    cd ./Publications.GooglePlay/

    adb exec-out screencap -p > Screenshot.Android_7inch.en.portrait.$(date +%Y-%m-%d).1.png
    adb exec-out screencap -p > Screenshot.Android_7inch.en.portrait.$(date +%Y-%m-%d).2.png
    ...

    for file in Screenshot.Android_7inch.en.portrait.$(date +%Y-%m-%d).*.png; do convert -quality 75 $file ${file/.png/.jpg}; done
    ```

    (The `convert` command requires to have ImageMagick installed.)

    Then upload the screensots to Google Play Console under "All Apps → Food Rescue → Store Entry".

    TODO: Adapt the screenshots command to create files with a sequential number in the last filename component automatically.


Note that, as an alternative to the process above, it should be possible to create an AAB package. An AAB (Android Application Bundle) combines the APK packages of multiple processor architectures (ABIs, meaning Application Binary Interface). This requires (1) enabling Google Play App Signing, which means trusting Google to sign your application's installable APKs which will be created by Google Play for devices automatically and (2) creating the AAB package with a modified build process. This [is possible](https://doc.qt.io/qt-5/android-publishing-to-googleplay.html), but it is not yet clear which version of `androiddeployqt` is necessary for that. (TODO: Find out and document how to build AAB packages.)


## 6.4. APK on website

The latest version of the Android build for ABI armeabi-v7a should always be uploaded to the project website, making it available under `http://fairdirect.org/downloads/foodrescue.apk`.

This is achieved with the following command (and the necessary password):

```
scp ~/Projects/Fairdirect.Food_Rescue_App/Repo.foodrescue-app/build/Android.ConsoleKit/foodrescue_build_apk/build/outputs/apk/release/foodrescue_build_apk-release.apk wp12504218@ssh.server-he.de:~/www/domain-fairdirect.org/downloads/foodrescue.apk
```


# 7. Style Guide

## 7.1. Code Style

The guiding idea is to write code that reads almost like natural language. That affects variable and method naming, source code layout and also choice of the logical flow and distributing algorithmic complexity so that one can understand everything while reading through once.

**Specific code style hints for C++:**

TODO

**Specific code style hints for QML:**

* **Assign IDs generously.** Every QML object can have an `id:` property, but only those references from the outside need one. However, assigning IDs with well-chosen names is code-as-documentation, defining the purpose and relations of the object without an additional comment.

* **Namespace use for imports.** All Qt5 provided QML is imported without a namespace – this is the "default stuff" that should be available directly. Everything else should be imported using a namespace, because only then it's clear where to look up documentation of an element found in the source code. (Also Kirigami uses some of the same names as Qt QML, which would add to the confusion without namespaces; e.g. Action, Label.) So all Kirigami QML imports are `import … as Kirigami` and all QML elements defined in the C++ part of this same application are imported as `import … as Local`.

* **Order of elements.** Use the following order when defining or instantiating and refining a QML type. It helps navigating the code because one will know where to look for a specific element, similar to how people often typically use an "attributes, public methods, private methods" order in classes.

    * **Identifying properties.** (`id`, `title` etc.)
    * **Custom signals, custom properties.**
    * **Properties.**
    * **Signal handlers, functions.** Similar to how methods typically come after attributes, we place behavior after properties.
    * **Invisible QML objects.** For example `Camera { … }`.
    * **Visible QML elements.** Nested in their layouts and in their visual order in the user interface (top to bottom, left to right). This can include both instantiated QML objects and properties (such as `Kirigami::Page.actions`) that define visual elements – which then is an exception from the rule above that places properties near the start.


## 7.2. Documentation Style

**Outsource to Stack Exchange.** To keep this README and other documentation short and to avoid mentioning the same instructions in multiple places, publish re-usable Q&A style instructions as answers to suitable questions on [StackOverflow](https://stackoverflow.com/) or if necessary one of its sister sites. And include just the hyperlink into the project documentation. This also lets others profit from your re-usable pieces of knowledge. Stack Exchange is reasonably stable, so it can be assumed that the links will rot slower than this software itself.


## 7.3. Software Design

TODO


# 8. Contribution Guide

TODO

As a contributor, you will have to sign a contributor licensing agreement that allows the person or organization directing the development of Food Rescue App to re-license the program under terms of their choice in the future without having to contact you first. This is done in preparation for the worst case, which is that we cannot establish a working sustainability model for Food Rescue App as an open source software. Of course, all previous versions including the one to which you contributed will remain under the open source licenses applied at the time when the contributions were made.


# 9. License and Credits

**Licenses.** This repository exclusively contains material under free software licencses and open content licenses. Unless otherwise noted in a specific file, all files are licensed under the MIT license. A copy of the license text is provided in [LICENSE.md](https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md).


**Credits, third-party licenses.** Within the rights granted by the applicable licenses, this repository contains works of the following open source projects, authors or groups, which are hereby credited for their contributions and for holding the copyright to their contributions. For the required formal license notes, see menu item "License Notes" in the application itself, or see the corresponding file `src/qml/LicensePage.qml`.

* **[Open Food Facts](https://openfoodfacts.org/).** This project relies heavily on the groundwork done by the open source [Open Food Facts](https://openfoodfacts.org/) project for creating a data commons for food products identified by a GTIN barcode. Actual content from Open Food Facts is included only via the [foodrescue-content](https://github.com/fairdirect/foodrescue-content) repository; see there for licencing details.

* **[Qt](https://qt.io/).** The best framework for cross-platform native applications. Licensed under the [GNU LGPL v3 license](https://www.gnu.org/licenses/lgpl-3.0.html). The Qt framework also contains multiple third-party libraries, licenced under various free software licences. For the full list, see [Licenses Used in Qt](https://doc.qt.io/qt-5/licenses-used-in-qt.html).

* **[Kirigami](https://kde.org/products/kirigami/).** A framework for mobile/desktop convergent applications, building on Qt Quick ("QML"). Licensed under the [LGPL v2 license](https://invent.kde.org/frameworks/kirigami/-/blob/master/LICENSE.LGPL-2).

* **[ZXing-C++](https://github.com/nu-book/zxing-cpp).** The most mature C++ version of the well-known barcode scanner library ZXing. Licensed under the [Apache License Version 2.0](https://github.com/nu-book/zxing-cpp/blob/master/LICENSE.ZXing).

* **[QZXingNu](https://github.com/swex/QZXingNu).** Provides a QML interface for the ZXing-C++ library.

* **[IQAndreas/markdown-licenses](https://github.com/IQAndreas/markdown-licenses).** Provides original open source licenses in Markdown format. The `LICENSE.md` file uses one of them.


**License issue: GPL add-ons.** The Qt framework comes with [multiple optional add-ons](https://doc.qt.io/qt-5/qtmodules.html#gpl-licensed-addons) that are licensed under the GPL v3 license. Some of them (esp. Qt Quick WebGL) can be used with this program. We are of the opinion that this fact does not bring Food Rescue App under the requirements of the GPL license; these requirements would be:

1. That the program itself is licensed under a GPL v3 compatible license ([see](https://www.gnu.org/licenses/gpl-faq.en.html#LinkingWithGPL)). While this is currently met by using MIT license, we want to keep the freedom of re-licensing it later.

2. That the binary distribution of the program is licensed under GPL v3 if that distribution includes the GPL'ed add-ons. This is currently met because no distribution of this program includes a Qt add-on that is GPL v3 licensed.

Our argument goes as follows: Food Rescue App is not designed to be used with any of the GPL-licensed add-ons. It does not call any code in any of them directly – the Qt framework itself does. Food Rescue App does also not distribute the GPL-licensed code of these add-ons, neither in source nor binary form. For this reason, Food Rescue App and these add-ons shall be considered [separate works](https://www.gnu.org/licenses/gpl-faq.en.html#GPLPlugins) and given that status, the GPL license of the add-on makes no requirement about the license of the main program ([see](https://www.gnu.org/licenses/gpl-faq.en.html#NFUseGPLPlugins)).

In fact, the program and these add-ons must be separate works because the authors of Food Rescue App are not necessarily aware of the existence of these add-ons and did not use them during development, which makes it impossible to create a combined work. The Qt WebGL add-on uses the standardized [Qt Platform Abstraction](https://doc.qt.io/qt-5/qpa.html) interface for rendering the program in a WebGL environment. Since this is a standard interface used by Qt used by all its non-GPL'ed other platform renderers as well, the fact that a GPL'ed add-on can be used with this program does not mean that the program was designed for it, and does not force the program under the GPL. If it were, on the other hand, possible to force a program under the GPL by writing an add-on that the authors of the original program are not even aware of, it would be clearly absurd.

Users are still free to install the WebGL add-on alongside this program and use them together. Using a program in any way does not force adopting the GPL, so you are not bound by the GPL in such a case. Users should however be aware that it is not legal to *distribute* this combination of programs, should Food Rescue App adopt a license in the future that is not compatible with the GPL v3.

For further reference:

* https://opensource.stackexchange.com/a/9438
* https://opensource.stackexchange.com/a/7259
* https://softwareengineering.stackexchange.com/a/367850
