# Food Rescue App

----
🚧 🚧 🚧 **This application is under construction.** 🚧 🚧 🚧

The code does not provide a useful application just yet. Check back at 2020-08-31 to find the first full release here!
----

**[1. Overview](#1-overview)**
**[2. Repository Structure](#2-repository-structure)**
**[3. Installation](#3-installation)**
**[4. Usage](#4-usage)**
**[5. Development Guide](#5-development-guide)**

  * [5.1. Development Setup](#51-development-setup)
  * [5.2. Build and Development Process](#52-build-and-development-process)
  * [5.3. Release Process](#53-release-process)
  * [5.4. Software Design](#54-software-design)
  * [5.5. Code Style Guide](#55-code-style-guide)
  * [5.6. Documentation Style Guide](#56-documentation-style-guide)

**[6. License and Credits](#6-license-and-credits)**

------


## 1. Overview

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

* **Other documentation.** Extensive project documentation about planned features, used technologies, frequent tasks and related projects and initiatives is available in a [Dynalist document](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA). The same content is also available as an exported version under `doc/doc.html` in this repository. But the export is still rough and does not support proper navigation in the document, so at this time the Dynalist live document is preferable.


## 2. Repository Structure

TODO


## 3. Installation

Right now, you would have to compile the software yourself from source ☹️ See sections [5.1. Development Setup](#51-development-setup) and [5.2. Build and Development Process](#52-build-and-development-process) below for that.

Eventually you will be able to install the software comfortably as follows:

* **For Android.** Install directly from [F-Droid](https://f-droid.org/) or [Google Play](https://play.google.com/store/apps). Or install from the [KDE Android F-Droid repository](https://community.kde.org/Android/FDroid), which also contains all other Kirigami based Android applications.

* **For iOS.** Install from the Apple App Store.

* **For Linux.** For Ubuntu 20.04 LTS and its variants, a Debian package is provided in a PPA package repository.

* **For Windows.** Download a self-extracting installer and install from there.

* **For Mac OS X.** Download a DMG package and install from there.


## 4. Usage

The following keyboard combinations are available:

* **Close the application.** Ctrl + Q (Kirigami default)
* **Select menu item.** Alt + highlighted letter while menu drawer is open


## 5. Development Guide

### 5.1. Development Setup

1. **Install the required dependencies.** The dependencies are chosen to be matched by the newest Ubuntu LTS releases. So for example, from 2020-04 to 2022-04 ([see](https://ubuntu.com/about/release-cycle)), releases will be installable under Ubuntu 20.04 LTS and you can use the packages from its standard repositories for development. (The project currently also builds under Ubuntu 19.10, but that is not guaranteed for the future.)

    If your distribution provides older versions of the following dependencies or you develop under Windows or Mac OS X, you have to install dependencies manually.

    * **KDE Kirigami 5.68.0 or higher.** [As provided](https://launchpad.net/ubuntu/focal/amd64/kirigami2-dev) under Ubuntu 20.04 LTS and installed there with:

        ```
        sudo apt install kirigami2-dev libkf5kirigami2-doc
        ```

        To install Kirigami 5.68.0 manually, choose the corresponding commit `f47bf906` ([source](https://invent.kde.org/frameworks/kirigami/-/tags)). Avoiding a higher version can be necessary if it does not build with your system's Qt libraries otherwise.

    * **Qt 5.12.0 or higher.** [As required](https://invent.kde.org/frameworks/kirigami/-/blob/f47bf90/CMakeLists.txt#L8) by KDE Kirigami 5.68.0, [corresponding to commit `f47bf906`](https://invent.kde.org/frameworks/kirigami/-/tags). Under Ubuntu 20.04 LTS, it is [installed automatically as a dependency](https://launchpad.net/ubuntu/focal/amd64/libkf5kirigami2-5/5.68.0-0ubuntu2).

    * **Breeze icon theme.** Under Ubuntu 20.04 LTS, install with:

        ```
        sudo apt install breeze-icon-theme
        ```

    * **Development tooling.** Under Ubuntu 20.04 LTS, install with:

         ```
         sudo apt install build-essential cmake extra-cmake-modules
         ```

2. **Clone the repository.**

    ```
    git clone git@github.com:fairdirect/foodrescue-app.git
    ```

3. **Adapt the CMake files.** There is a marked section at the beginning of `./CMakeLists.txt` that you have to adapt to your system. (This will be fixed in a later version, since Makefiles should not include system-specific configuration.)


### 5.2. Build and Development Process

**To build the software using the command line:**

```
cd example && mkdir build && cd build
cmake ..
make
```

(TODO: How to build the various targets, such as an Android APK etc.. How to deploy to a phone and run it there.)

**To build the software with Qt Creator:**

1. "File → Open File or Project.." and open the project's `CMakeLists.txt`. (This is how you open CMake projects with Qt Creator.)

2. Select the "Projects" tab from the sidebar and configure the project's build targets (TODO: how).

3. In the lower left build control toolbar, select your build target and then click the large green "Run" button.


### 5.3. Release Process

TODO


### 5.4. Software Design

TODO


### 5.5. Code Style Guide

The guiding idea is to write code that reads almost like natural language. That affects variable and method naming, source code layout and also choice of the logical flow and distributing algorithmic complexity so that one can understand everything while reading through once.

For C++ code, this means specifically:

TODO

And for QML code, this means specifically:

* **Visual order.** Order code elements as much as possible in the order they will appear in the user interface (top to bottom, left to right). If that means mixing contained QML types and QML attributes, so be it.


### 5.6. Documentation Style Guide

TODO


## 6. License and Credits

**Licenses.** This repository exclusively contains material under free software licencses and open content licenses. Unless otherwise noted in a specific file, all files are licensed under the MIT license. A copy of the license text is provided in [LICENSE.md](https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md).


**Credits.** Within the rights granted by the applicable licenses, this repository contains works of the following open source projects, authors or groups, which are hereby credited for their contributions and for holding the copyright to their contributions:

* **[Open Food Facts](https://openfoodfacts.org/).** This project relies heavily on the groundwork done by the open source [Open Food Facts](https://openfoodfacts.org/) project for creating a data commons for food products identified by a GTIN barcode. Actual content from Open Food Facts is included only via the [foodrescue-content](https://github.com/fairdirect/foodrescue-content) repository; see there for licencing details.

* **[IQAndreas/markdown-licenses](https://github.com/IQAndreas/markdown-licenses).** Provides orginal open source licenses in Markdown format. The `LICENSE.md` file uses one of them.

* **[Qt](https://qt.io/) and [KDE Kirigami](https://kde.org/products/kirigami/) developers.** For making the best convergent application development framework to date.
