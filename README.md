# Food Rescue App


**Table of Contents**

**[1. Overview](#1-overview)**

**[2. Repository Structure](#2-repository-structure)**

**[3. Installation](#3-installation)**

**[4. Usage](#4-usage)**

**[5. Development Guide](#5-development-guide)**

  * [5.1. Development Setup](#51-development-setup)
  * [5.2. Build and Development Process](#52-build-and-development-process)
  * [5.3. Software Design](#53-software-design)
  * [5.4. Code Style Guide](#54-code-style-guide)
  * [5.5. Documentation Style Guide](#55-documentation-style-guide)

**[6. License and Credits](#6-license-and-credits)**

------


## 1. Overview

This repository contains an open source application to help assess if food is still edible or not. The actual content shown inside this application is contained and processed in repository [foodrescue-content](https://github.com/fairdirect/foodrescue-content).

**Features:**

* **Convergent.** The application runs from the same codebase and with the same user interface as a native (!) application on both phones, tablets and desktop computers. This is made possible by Qt5 and, based on that, the [KDE Kirigami](https://kde.org/products/kirigami/) framework.

* **Cross-platform.** The application is cross-platform, running on all platforms supported by the KDE Kirigami framework. As of 2020-06, these are: Android, iOS, Windows, Mac OS X, Linux.

* **Scan to check.** To quickly find the required information about a food item, scan its GTIN barcode with the camera of your device.

**Documentation:**

* **Project website.** The project's website with introductory information and relevant links is [fairdirect.org/food-rescue-app](https://fairdirect.org/food-rescue-app).

* **API documentation.** The project's C++ source files contain in-code documentation that you can compile into full API docs with [Doxygen](https://www.doxygen.nl/).

* **Other documentation.** Extensive project documentation about planned features, used technologies, frequent tasks and related projects and initiatives is available in a [Dynalist document](https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA). The same content is also available as an exported version under `doc/doc.html` in this repository. But the export is still rough and does not support proper navigation in the document, so at this time the Dynalist live document is preferable.


## 2. Repository Structure

TODO


## 3. Installation

Right now, you would have to compile the software yourself from source ☹️

Eventually you will be able to install the software comfortably as follows:

* **For Android.** Install directly from [F-Droid](https://f-droid.org/) or [Google Play](https://play.google.com/store/apps). Or install from the [KDE Android F-Droid repository](https://community.kde.org/Android/FDroid), which also contains all other Kirigami based Android applications.

* **For iOS.** Install from the Apple App Store.

* **For Linux.** Install from a Debian package provided in a PPA package repository.

* **For Windows.** Download a self-extracting installer and install from there.

* **For Mac OS X.** Download a DMG package and install from there.


## 4. Usage

TODO


## 5. Development Guide

### 5.1. Development Setup

TODO


### 5.2. Build and Development Process

TODO


### 5.3. Software Design

TODO


### 5.4. Code Style Guide

The guiding idea is to write code that reads almost like natural language. That affects variable and method naming, source code layout and also choice of the logical flow and distributing algorithmic complexity so that one can understand everything while reading through once.

For C++ code, this means specifically:

TODO

And for QML code, this means specifically:

TODO


### 5.5. Documentation Style Guide

TODO


## 6. License and Credits

**Licenses.** This repository exclusively contains material under free software licencses and open content licenses. Unless otherwise noted in a specific file, all files are licensed under the MIT license. A copy of the license text is provided in [LICENSE.md](https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md).


**Credits.** Within the rights granted by the applicable licenses, this repository contains works of the following open source projects, authors or groups, which are hereby credited for their contributions and for holding the copyright to their contributions:

* **[Open Food Facts](https://openfoodfacts.org/).** This project relies heavily on the groundwork done by the open source [Open Food Facts](https://openfoodfacts.org/) project for creating a data commons for food products identified by a GTIN barcode. Actual content from Open Food Facts is included only via the [foodrescue-content](https://github.com/fairdirect/foodrescue-content) repository; see there for licencing details.

* **[IQAndreas/markdown-licenses](https://github.com/IQAndreas/markdown-licenses).** Provides orginal open source licenses in Markdown format. The `LICENSE.md` file uses one of them.

* **[Qt](https://qt.io/) and [KDE Kirigami](https://kde.org/products/kirigami/) developers.** For making the best convergent application development framework to date.
