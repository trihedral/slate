/*
    Copyright 2020, Mitch Curtis

    This file is part of Slate.

    Slate is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Slate is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Slate. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import App 1.0

import "." as Ui

ItemDelegate {
    id: root
    objectName: model.animation.name
    checkable: true
    checked: animationSystem && animationSystem.currentAnimationIndex === index
    implicitHeight: Math.max(implicitBackgroundHeight, animationNameTextField.implicitHeight + topPadding + bottomPadding)
    leftPadding: thumbnailPreview.width + 18
    topPadding: 0
    bottomPadding: 0
    focusPolicy: Qt.NoFocus

    property var project
    property ImageCanvas canvas
    readonly property AnimationSystem animationSystem: project ? project.animationSystem : null

    signal editingFinished

    onClicked: project.animationSystem.currentAnimationIndex = index
    onDoubleClicked: animationNameTextField.forceActiveFocus()

    SpriteImageContainer {
        id: thumbnailPreview
        objectName: "thumbnailPreview"
        x: 14
        project: root.project
        animationPlayback: AnimationPlayback {
            objectName: root.objectName + "AnimationPlayback"
            animation: model.animation
            // Fit us in the thumbnail.
            scale: Math.min(thumbnailPreview.width / animation.frameWidth, thumbnailPreview.height / animation.frameHeight)
        }
        width: height
        height: parent.height
    }

    // TODO: try to move this whole delegate into EditableDelegate.qml
    // so LayerDelegate and AnimationDelegate can reuse the code
    TextField {
        id: animationNameTextField
        objectName: "animationNameTextField"
        text: model.animation.name
        font.family: "FontAwesome"
        activeFocusOnPress: false
        anchors.left: thumbnailPreview.right
        anchors.leftMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: parent.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 6
        background.visible: false
        font.pixelSize: 12
        visible: false

        onAccepted: {
            model.animation.name = text
            animationSystem.animationModified(index)
            // We call it "editingFinished", but it's not the same as TextField's signal,
            // which is only emitted when it loses focus. We need to handle the accepted
            // and rejected signals separately, and also take care of relieving ourselves
            // of focus (which is done by the calling code via the editingFinished signal).
            root.editingFinished()
        }

        Keys.onEscapePressed: {
            text = model.animation.name

            root.editingFinished()
        }
    }

    // We don't want TextField's editable cursor to be visible,
    // so we set visible: false to disable the cursor, and instead
    // render it via this.
    ShaderEffectSource {
        sourceItem: animationNameTextField
        anchors.fill: animationNameTextField
    }

    // Apparently the one above only works for the top level control item,
    // so we also need one for the background.
    ShaderEffectSource {
        sourceItem: animationNameTextField.background
        x: animationNameTextField.x + animationNameTextField.background.x
        y: animationNameTextField.y + animationNameTextField.background.y
        width: animationNameTextField.background.width
        height: animationNameTextField.background.height
        visible: animationNameTextField.activeFocus
    }

    Rectangle {
        id: focusRect
        width: 2
        height: parent.height
        color: Ui.Theme.focusColour
        visible: parent.checked
    }
}