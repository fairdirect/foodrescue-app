import QtQuick 2.1
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

Repeater {
    model: suggestions

    property int currentIndex: 2

    Component.onCompleted: {
        console.log("suggestions.currentIndex: " + suggestions.currentIndex)
        suggestions.currentIndex = 2
        console.log("suggestions.currentIndex: " + suggestions.currentIndex)
        currentIndex = 2
        console.log("suggestions.currentIndex: " + suggestions.currentIndex)
    }

}
