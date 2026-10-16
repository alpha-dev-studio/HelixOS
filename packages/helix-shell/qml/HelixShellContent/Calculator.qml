import QtQuick
import HelixShell

// HelixOS Calculator: fully working (plain QML carries the math).
Rectangle {
    id: win
    width: 340
    height: 520
    radius: 12
    color: "#26262E"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea
    property string expr: ""
    property string display: "0"
    property bool fresh: true

    function evaluate(e) {
        var toks = e.match(/(\d+\.?\d*|[+\-*/])/g);
        if (!toks || toks.length === 0) {
            return "0";
        }
        var values = [parseFloat(toks[0])];
        if (isNaN(values[0])) {
            return "Error";
        }
        for (var i = 1; i < toks.length; i += 2) {
            var op = toks[i];
            var v = parseFloat(toks[i + 1]);
            if (isNaN(v)) {
                return "Error";
            }
            if (op === "*" || op === "/") {
                var a = values.pop();
                values.push(op === "*" ? a * v : a / v);
            } else if (op === "+") {
                values.push(v);
            } else if (op === "-") {
                values.push(-v);
            } else {
                return "Error";
            }
        }
        var total = 0;
        for (var j = 0; j < values.length; j++) {
            total += values[j];
        }
        if (!isFinite(total)) {
            return "Error";
        }
        var rounded = Math.round(total * 100000000) / 100000000;
        return String(rounded);
    }

    function press(key) {
        if (key === "C") {
            expr = "";
            display = "0";
            fresh = true;
        } else if (key === "=") {
            if (expr !== "") {
                display = evaluate(expr);
                expr = display === "Error" ? "" : display;
                fresh = true;
            }
        } else if (key === "back") {
            expr = expr.slice(0, -1);
            display = expr === "" ? "0" : expr;
        } else if (key === "neg") {
            if (display !== "0" && display !== "Error") {
                if (expr.charAt(0) === "-") {
                    expr = expr.slice(1);
                } else {
                    expr = "-" + expr;
                }
                display = expr;
            }
        } else if (key === "%") {
            var n = parseFloat(display);
            if (!isNaN(n)) {
                display = String(n / 100);
                expr = display;
                fresh = true;
            }
        } else {
            if (fresh && "0123456789.".indexOf(key) >= 0) {
                expr = "";
                fresh = false;
            }
            if (key === "." && /(^|[+\-*/])[^+\-*/]*\./.test(expr + ".")) {
                return;
            }
            expr += key;
            display = expr;
            fresh = false;
        }
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
            text: qsTr("Calculator")
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

    Text {
        x: 20
        y: 60
        width: parent.width - 40
        text: expr === "" ? qsTr("") : expr
        color: "#6E6E78"
        font.pixelSize: 15
        horizontalAlignment: Text.AlignRight
    }
    Text {
        x: 20
        y: 88
        width: parent.width - 40
        text: display
        color: "#F2F2F2"
        font.pixelSize: 44
        font.weight: Font.Light
        horizontalAlignment: Text.AlignRight
    }

    Grid {
        x: 16
        y: 170
        columns: 4
        columnSpacing: 10
        rowSpacing: 10
        Repeater {
            model: [
                { label: "C", key: "C", accent: true },
                { label: "⌫", key: "back", accent: true },
                { label: "%", key: "%", accent: true },
                { label: "÷", key: "/", accent: true },
                { label: "7", key: "7", accent: false },
                { label: "8", key: "8", accent: false },
                { label: "9", key: "9", accent: false },
                { label: "×", key: "*", accent: true },
                { label: "4", key: "4", accent: false },
                { label: "5", key: "5", accent: false },
                { label: "6", key: "6", accent: false },
                { label: "−", key: "-", accent: true },
                { label: "1", key: "1", accent: false },
                { label: "2", key: "2", accent: false },
                { label: "3", key: "3", accent: false },
                { label: "+", key: "+", accent: true },
                { label: "±", key: "neg", accent: false },
                { label: "0", key: "0", accent: false },
                { label: ".", key: ".", accent: false },
                { label: "=", key: "=", accent: true }
            ]
            delegate: Rectangle {
                id: keyBtn
                width: 72
                height: 62
                radius: 8
                color: "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    color: modelData.accent ? "#00F0FF" : "#F2F2F2"
                    font.pixelSize: 20
                    font.bold: true
                }
                MouseArea {
                    id: keyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: press(modelData.key)
                }
                states: [
                    State {
                        name: "hover"
                        when: keyMouse.containsMouse && !keyMouse.pressed
                        PropertyChanges { target: keyBtn; color: "#3E3E48" }
                    },
                    State {
                        name: "pressed"
                        when: keyMouse.pressed
                        PropertyChanges { target: keyBtn; color: "#00F0FF" }
                    }
                ]
                transitions: Transition {
                    ColorAnimation { duration: 100 }
                }
            }
        }
    }
}
