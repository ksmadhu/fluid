/****************************************************************************
 * This file is part of Fluid.
 *
 * Copyright (c) 2012 Pier Luigi Fiorini
 * Copyright (c) 2011 Daker Fernandes Pinheiro
 * Copyright (c) 2011 Mark Gaiser
 * Copyright (c) 2011 Marco Martin
 *
 * Author(s):
 *    Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *    Mark Gaiser <markg85@gmail.com>
 *    Marco Martin <mart@kde.org>
 *    Daker Fernandes Pinheiro <dakerfp@gmail.com>
 *
 * $BEGIN_LICENSE:LGPL2.1+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 ***************************************************************************/

/**Documented API
Inherits:
        Item

Imports:
        QtQuick 2.0
        FluidCore

Description:
        A simple button, with optional label and icon which uses the plasma theme.
	This button component can also be used as a checkable button by using the checkable
	and checked properties for that.
        Plasma theme is the theme which changes via the systemsetting-workspace appearance
        -desktop theme.

Properties:
      * bool checked:
        This property holds whether this button is checked or not.
	The button must be in the checkable state for enable users check or uncheck it.
	The default value is false.
	See also checkable property.

      * bool checkable:
        This property holds if the button is acting like a checkable button or not.
	The default value is false.

       * bool pressed:
        This property holds if the button is pressed or not.
	Read-only.

      * string text:
        This property holds the text label for the button.
        For example,the ok button has text 'ok'.
	The default value for this property is an empty string.

      * url iconSource:
        This property holds the source url for the Button's icon.
        The default value is an empty url, which displays no icon.
        It can be any image from any protocol supported by the Image element, or a freedesktop-compatible icon name.

      * font font:
        This property holds the font used by the button label.
	See also Qt documentation for font type.

Signals:
      * clicked():
        This handler is called when there is a click.
**/

import QtQuick 2.0

import FluidCore 1.0 as FluidCore
import "private" as Private

Item {
    id: button

    // Commmon API
    property bool checked: false
    property bool checkable: false
    property alias pressed: mouse.pressed
    property alias text: label.text
    property alias iconSource: icon.source
    property alias font: label.font

    signal clicked()

    // Internal style API
property color textColor
    property color pressedTextColor: textColor
    property color disabledTextColor: textColor
    property color checkedTextColor: textColor

    property int backgroundMarginRight: 5
    property int backgroundMarginLeft: 5
    property int backgroundMarginTop: 5
    property int backgroundMarginBottom: 5

    property url background: "images/button.png"
    property url hoverBackground: "images/button-hover.png"
    property url focusedBackground: "images/button-focused.png"
    property url focusedHoverBackground: "images/button-focused-hover.png"
    property url disabledBackground: "images/button-disabled.png"
    property url pressedBackground: "images/button-active.png"
    property url pressedHoverBackground: "images/button-active-hover.png"
    property url pressedFocusedBackground: "images/button-active-focused.png"
    property url pressedFocusedHoverBackground: "images/button-active-focused-hover.png"
    property url pressedDisabledBackground: "images/button-active-disabled.png"
    //
    property url defaultBackground: "images/button-default.png"
    property url defaultHoverBackground: "images/button-default-hover.png"

    implicitWidth: {
        if (label.paintedWidth == 0)
            return height;
        return Math.max(theme.defaultFont.mSize.width * 12,
            icon.width + label.paintedWidth + backgroundMarginLeft + backgroundMarginRight) + ((icon.valid) ? backgroundMarginLeft : 0);
    }
    implicitHeight: Math.max(theme.defaultFont.mSize.height * 1.6, Math.max(icon.height, label.paintedHeight) + backgroundMarginTop/2 + backgroundMarginBottom/2)

    // TODO: needs to define if there will be specific graphics for
    //     disabled buttons
    opacity: enabled ? 1.0 : 0.5

    QtObject {
        id: internal
        property bool userPressed: false

        function belongsToButtonGroup()
        {
            return button.parent
                   && button.parent.hasOwnProperty("checkedButton")
                   && button.parent.exclusive
        }

        function clickButton()
        {
            userPressed = false
            if (!button.enabled) {
                return
            }

            if ((!belongsToButtonGroup() || !button.checked) && button.checkable) {
                button.checked = !button.checked
            }

            button.forceActiveFocus()
            button.clicked()
        }
    }

    Keys.onSpacePressed: internal.userPressed = true
    Keys.onReturnPressed: internal.userPressed = true
    Keys.onReleased: {
        internal.userPressed = false
        if (event.key == Qt.Key_Space ||
            event.key == Qt.Key_Return)
            internal.clickButton();
    }

    BorderImage {
        id: backgroundImage
        anchors.fill: parent
        source: {
            if (button.enabled) {
                var pressed = internal.userPressed || checked;

                if (button.activeFocus && mouse.containsMouse)
                    return pressed ? button.pressedFocusedHoverBackground : button.focusedHoverBackground;
                else if (mouse.containsMouse)
                    return pressed ? button.pressedHoverBackground : button.hoverBackground;
                else if (button.activeFocus)
                    return pressed ? button.pressedFocusedBackground : button.focusedBackground;
                return pressed ? button.pressedBackground : button.background;
            } else {
                if (internal.userPressed || checked)
                    return button.pressedDisabledBackground;
                return button.disabledBackground;
            }
        }
        border {
            left: button.backgroundMarginLeft
            top: button.backgroundMarginTop
            right: button.backgroundMarginRight
            bottom: button.backgroundMarginBottom
        }
    }

    Item {
        id: buttonContent
        anchors {
            fill: parent
            leftMargin: button.backgroundMarginLeft
            topMargin: button.backgroundMarginTop
            rightMargin: button.backgroundMarginRight
            bottomMargin: button.backgroundMarginBottom
        }

        Private.IconLoader {
            id: icon

            anchors {
                verticalCenter: parent.verticalCenter
                left: label.paintedWidth > 0 ? parent.left : undefined
                horizontalCenter: label.paintedWidth > 0 ? undefined : parent.horizontalCenter
            }
            height: roundToStandardSize(parent.height)
            width: height
        }

        Text {
            id: label

            //FIXME: why this is needed?
            onPaintedWidthChanged: {
                icon.anchors.horizontalCenter = label.paintedWidth > 0 ? undefined : icon.parent.horizontalCenter
                icon.anchors.left = label.paintedWidth > 0 ? icon.parent.left : undefined
            }
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: icon.valid ? icon.right : parent.left
                leftMargin: icon.valid ? parent.anchors.leftMargin : 0
            }

            font.capitalization: theme.defaultFont.capitalization
            font.family: theme.defaultFont.family
            font.italic: theme.defaultFont.italic
            font.letterSpacing: theme.defaultFont.letterSpacing
            font.pointSize: theme.defaultFont.pointSize
            font.strikeout: theme.defaultFont.strikeout
            font.underline: theme.defaultFont.underline
            font.weight: theme.defaultFont.weight
            font.wordSpacing: theme.defaultFont.wordSpacing
            color: !button.enabled ? button.disabledTextColor : (button.pressed ? button.pressedTextColor : (button.checked ? button.checkedTextColor : theme.buttonTextColor))
            horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        onPressed: internal.userPressed = true
        onReleased: internal.userPressed = false
        onCanceled: internal.userPressed = false
        onClicked: internal.clickButton()
    }
}
