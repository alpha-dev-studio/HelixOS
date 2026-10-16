import QtQuick
import HelixShell

// HelixOS Paint: a real mini painter (plain QML carries the strokes).
Rectangle {
    id: win
    width: 800
    height: 600
    radius: 10
    color: "#26262E"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea
    property color brush: "#00F0FF"
    property real brushSize: 6
    property var strokes: []
    property var current: []

    function redraw() {
        paint.requestPaint();
    }

    Rectangle {
        height: 42
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#1C1C24"
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Helix Paint — untitled")
            color: "#F2F2F2"
            font.pixelSize: 14
            font.bold: true
        }
        MouseArea {
            anchors.fill: parent
            drag.target: win
            drag.axis: Drag.XAndYAxis
        }
        Rectangle {
            id: maxBtn
            width: 46
            height: 42
            anchors.right: parent.right
            anchors.rightMargin: 46
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u25A2")
                color: "#F2F2F2"
                font.pixelSize: 12
            }
            MouseArea {
                id: maxMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: maxMouseArea.containsMouse
                PropertyChanges { target: maxBtn; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
        Rectangle {
            id: minBtn
            width: 46
            height: 42
            anchors.right: parent.right
            anchors.rightMargin: 92
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u2212")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: minMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: minMouseArea.containsMouse
                PropertyChanges { target: minBtn; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
        Rectangle {
            id: closeBtn
            width: 46
            height: 42
            anchors.right: parent.right
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u2715")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: closeMouseArea.containsMouse
                PropertyChanges { target: closeBtn; color: "#C42B1C" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
    }

    // toolbar
    Row {
        x: 16
        y: 56
        spacing: 10
        Repeater {
            model: ["#00F0FF", "#C6FF00", "#B44DFF", "#F2F2F2", "#FF5C5C"]
            delegate: Rectangle {
                width: 36
                height: 36
                radius: 18
                color: modelData
                border.color: "white"
                border.width: brush == modelData ? 3 : 0
                MouseArea {
                    anchors.fill: parent
                    onClicked: brush = modelData
                }
            }
        }
        Rectangle {
            width: 90
            height: 36
            radius: 8
            color: "#34343E"
            Text {
                anchors.centerIn: parent
                text: qsTr("Clear")
                color: "#F2F2F2"
                font.pixelSize: 13
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    strokes = [];
                    current = [];
                    paint.requestPaint();
                }
            }
        }
    }

    // canvas
    Rectangle {
        x: 16
        y: 106
        width: parent.width - 32
        height: parent.height - 122
        radius: 8
        color: "#101018"
        clip: true
        Canvas {
            id: paint
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                for (var s = 0; s < strokes.length; s++) {
                    var st = strokes[s];
                    if (st.points.length < 1) {
                        continue;
                    }
                    ctx.strokeStyle = st.color;
                    ctx.lineWidth = brushSize;
                    ctx.beginPath();
                    ctx.moveTo(st.points[0].x, st.points[0].y);
                    for (var p = 1; p < st.points.length; p++) {
                        ctx.lineTo(st.points[p].x, st.points[p].y);
                    }
                    ctx.stroke();
                }
                if (current.length > 0) {
                    ctx.strokeStyle = brush;
                    ctx.lineWidth = brushSize;
                    ctx.beginPath();
                    ctx.moveTo(current[0].x, current[0].y);
                    for (var q = 1; q < current.length; q++) {
                        ctx.lineTo(current[q].x, current[q].y);
                    }
                    ctx.stroke();
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onPressed: {
                current = [{ x: mouse.x, y: mouse.y }];
                paint.requestPaint();
            }
            onPositionChanged: {
                current.push({ x: mouse.x, y: mouse.y });
                paint.requestPaint();
            }
            onReleased: {
                if (current.length > 0) {
                    strokes.push({ color: brush, points: current });
                }
                current = [];
                paint.requestPaint();
            }
        }
    }
}
