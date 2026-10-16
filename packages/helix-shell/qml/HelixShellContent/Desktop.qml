import QtQuick
import HelixShell

// HelixOS desktop shell: full window management (min/max, tri-state pins),
// theming (wallpaper + accent), and the complete app suite.
// Visual forms stay in *.ui.qml (Design Studio editable); behavior lives here.
Item {
    id: root
    width: Constants.width
    height: Constants.height
    focus: true

    // ---- shell state ----
    property bool unlocked: false
    property bool menuOpen: false
    property bool calOpen: false
    property bool notifOpen: false
    property bool trayOpen: false
    property bool contextShown: false
    property real contextX: 0
    property real contextY: 0
    property string timeText: "12:00"
    property string dateText: "10/15/2026"
    property string lockDateText: "Wednesday, October 15"
    property var calDays: []
    property string calTitle: ""
    property int calOffset: 0
    property int todayIndex: -1
    property bool wifiOn: true
    property bool btOn: false
    property bool nightOn: false
    property bool cleared: false

    // ---- theming + identity ----
    property int wallpaperTheme: 0
    property color accent: "#00F0FF"
    property string userName: "helix"
    property string taskAlign: "center"
    property string menuView: "main"
    property string filesPath: ""
    property string filesCrumbText: "Home"

    // ---- OS bridge (null in Design Studio preview; live on device) ----
    property var helix: (typeof Helix !== "undefined") ? Helix : null
    property string battInfo: "82%"
    property string battState: "discharging"
    property real volLevel: 0.6
    property real brightLevel: 0.8
    property var wifiNetworks: []
    property var procs: []
    property var homeFiles: []
    property var resolutions: ["1920 x 1080", "1600 x 900", "1366 x 768", "1280 x 720"]
    property string updatesText: "Check for HelixOS system updates."
    property int tick: 0

    // ---- app windows ----
    property bool settingsOpen: false
    property bool filesOpen: false
    property bool storeOpen: false
    property bool terminalOpen: false
    property bool calcOpen: false
    property bool taskmgrOpen: false
    property bool paintOpen: false
    property bool shutdownOpen: false
    property string settingsPage: "wifi"
    property bool updatesChecked: false
    property bool storeInstalling: false
    property real storeProgress: 0.0
    property bool storeInstalled: false

    // ---- first run + switcher ----
    property bool oobeDone: false
    property int oobeStep: 0
    property bool altTabShown: false
    property int altTabIndex: 0

    // ---- window management ----
    property string maxed: ""
    property var minimized: []
    property string topWin: ""

    function closeFlyouts() {
        menuOpen = false;
        calOpen = false;
        notifOpen = false;
        trayOpen = false;
        contextShown = false;
    }

    function enterFolder(name) {
        if (filesPath === "" || filesPath === "trash://") {
            filesPath = name;
        } else {
            filesPath = filesPath + "/" + name;
        }
        refreshFilesCrumb();
    }

    function backFolder() {
        if (filesPath === "" || filesPath === "trash://") {
            filesPath = "";
        } else {
            var i = filesPath.lastIndexOf("/");
            filesPath = i < 0 ? "" : filesPath.slice(0, i);
        }
        refreshFilesCrumb();
    }

    function refreshFilesCrumb() {
        if (filesPath === "") {
            filesCrumbText = "Home";
        } else if (filesPath === "trash://") {
            filesCrumbText = "Recycle Bin";
        } else {
            var parts = filesPath.split("/");
            filesCrumbText = parts[parts.length - 1];
        }
    }

    function openApp(name) {
        closeFlyouts();
        shutdownOpen = false;
        topWin = name;
        menuView = "main";
        minimized = minimized.filter(function(m) { return m !== name; });
        if (name === "settings") {
            settingsOpen = true;
        } else if (name === "files") {
            filesOpen = true;
        } else if (name === "store") {
            storeOpen = true;
        } else if (name === "terminal") {
            terminalOpen = true;
        } else if (name === "calc") {
            calcOpen = true;
        } else if (name === "taskmgr") {
            taskmgrOpen = true;
        } else if (name === "paint") {
            paintOpen = true;
        } else if (name === "shutdown") {
            shutdownOpen = true;
        }
    }

    function isMinimized(name) {
        return minimized.indexOf(name) !== -1;
    }

    function minimizeApp(name) {
        if (!isMinimized(name)) {
            minimized = minimized.concat([name]);
        }
    }

    function toggleMax(name) {
        if (maxed === name) {
            maxed = "";
        } else {
            maxed = name;
        }
    }

    function pinClicked(name, isOpen) {
        if (!isOpen) {
            openApp(name);
        } else if (isMinimized(name)) {
            openApp(name);
        } else {
            minimizeApp(name);
        }
    }

    function rebuildCalendar() {
        var now = new Date();
        var first = new Date(now.getFullYear(), now.getMonth() + calOffset, 1);
        var y = first.getFullYear();
        var m = first.getMonth();
        calTitle = Qt.formatDate(first, "MMMM yyyy");
        var startDay = new Date(y, m, 1).getDay();
        var dim = new Date(y, m + 1, 0).getDate();
        var arr = [];
        for (var i = 0; i < 42; i++) {
            var n = i - startDay + 1;
            arr.push((n >= 1 && n <= dim) ? n : "");
        }
        calDays = arr;
        var t = new Date();
        if (calOffset === 0 && t.getFullYear() === y && t.getMonth() === m) {
            todayIndex = t.getDate() + startDay - 1;
        } else {
            todayIndex = -1;
        }
    }

    // ---- layers ----
    Wallpaper {
        anchors.fill: parent
        theme: wallpaperTheme
        glow: accent
    }

    MouseArea {
        id: rightCatcher
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            contextX = mouse.x;
            contextY = mouse.y;
            var was = contextShown;
            closeFlyouts();
            contextShown = !was;
        }
    }

    DesktopIcons {
        id: icons
        x: 24
        y: 24
    }

    Connections {
        target: icons.iconPcMouse
        function onClicked() {
            filesPath = "";
            openApp("files");
        }
    }
    Connections {
        target: icons.iconBinMouse
        function onClicked() {
            filesPath = "trash://";
            openApp("files");
        }
    }
    Connections {
        target: icons.iconWebMouse
        function onClicked() {
            if (helix) {
                helix.launch("firefox-esr");
            }
        }
    }
    Connections {
        target: icons.iconFilesMouse
        function onClicked() {
            filesPath = "";
            openApp("files");
        }
    }
    Connections {
        target: filesWin
        function onFolderOpened(name) { enterFolder(name); }
    }
    Connections {
        target: filesWin
        function onBackRequested() { backFolder(); }
    }

    MouseArea {
        id: dismissLayer
        anchors.fill: parent
        visible: menuOpen || calOpen || notifOpen || trayOpen || contextShown
        onClicked: closeFlyouts()
    }

    StartMenu {
        id: menu
        x: (root.width - width) / 2
        y: root.height - 48 - height - 12
        z: 15
        open: menuOpen
        paintInstalled: storeInstalled
        userName: root.userName
        view: menuView
    }

    CalendarCard {
        id: cal
        x: root.width - width - 12
        y: root.height - 48 - height - 12
        z: 15
        open: calOpen
        days: calDays
        monthTitle: calTitle
        todayIndex: root.todayIndex
    }

    TrayFlyout {
        id: tray
        x: root.width - width - 12
        y: root.height - 48 - height - 12
        z: 15
        open: trayOpen
        wifiOn: root.wifiOn
        volLevel: root.volLevel
        brightLevel: root.brightLevel
        battPct: battInfo
        battDetail: "Battery — " + battInfo
    }

    NotificationCenter {
        id: notif
        x: root.width - width - 12
        y: 12
        z: 15
        height: root.height - 48 - 24
        open: notifOpen
        wifiOn: root.wifiOn
        btOn: root.btOn
        nightOn: root.nightOn
        cleared: root.cleared
        brightLevel: root.brightLevel
    }

    DesktopMenu {
        id: ctxMenu
        x: Math.min(contextX, root.width - width)
        y: Math.min(contextY, root.height - 48 - height)
        z: 15
        shown: contextShown
    }

    // ---- app windows ----
    SettingsApp {
        id: settingsWin
        x: maxed === "settings" ? 0 : 420
        y: maxed === "settings" ? 0 : 180
        width: maxed === "settings" ? root.width : 920
        height: maxed === "settings" ? root.height - 48 : 600
        z: topWin === "settings" ? 5 : 1
        visible: settingsOpen && !isMinimized("settings")
        page: settingsPage
        wifiOn: root.wifiOn
        btOn: root.btOn
        accent: root.accent
        wallpaperTheme: root.wallpaperTheme
        userName: root.userName
        updatesChecked: root.updatesChecked
        taskAlign: root.taskAlign
        networks: wifiNetworks
        resolutions: root.resolutions
        brightLevel: root.brightLevel
        volLevel: root.volLevel
        battLine: "Battery: " + battInfo + " — " + battState
    }
    FilesApp {
        id: filesWin
        x: maxed === "files" ? 0 : 480
        y: maxed === "files" ? 0 : 220
        width: maxed === "files" ? root.width : 900
        height: maxed === "files" ? root.height - 48 : 560
        z: topWin === "files" ? 5 : 1
        visible: filesOpen && !isMinimized("files")
        files: homeFiles
        crumb: filesCrumbText
    }
    StoreApp {
        id: storeWin
        x: maxed === "store" ? 0 : 450
        y: maxed === "store" ? 0 : 200
        width: maxed === "store" ? root.width : 900
        height: maxed === "store" ? root.height - 48 : 600
        z: topWin === "store" ? 5 : 1
        visible: storeOpen && !isMinimized("store")
        installing: storeInstalling
        progress: storeProgress
        installed: storeInstalled
    }
    TerminalApp {
        id: terminalWin
        x: maxed === "terminal" ? 0 : 540
        y: maxed === "terminal" ? 0 : 260
        width: maxed === "terminal" ? root.width : 720
        height: maxed === "terminal" ? root.height - 48 : 460
        z: topWin === "terminal" ? 5 : 1
        visible: terminalOpen && !isMinimized("terminal")
    }
    Calculator {
        id: calcWin
        x: maxed === "calc" ? 0 : 760
        y: maxed === "calc" ? 0 : 240
        width: maxed === "calc" ? root.width : 340
        height: maxed === "calc" ? root.height - 48 : 520
        z: topWin === "calc" ? 5 : 1
        visible: calcOpen && !isMinimized("calc")
    }
    TaskManager {
        id: taskmgrWin
        x: maxed === "taskmgr" ? 0 : 560
        y: maxed === "taskmgr" ? 0 : 200
        width: maxed === "taskmgr" ? root.width : 760
        height: maxed === "taskmgr" ? root.height - 48 : 540
        z: topWin === "taskmgr" ? 5 : 1
        visible: taskmgrOpen && !isMinimized("taskmgr")
        procs: root.procs
    }
    PaintApp {
        id: paintWin
        x: maxed === "paint" ? 0 : 500
        y: maxed === "paint" ? 0 : 210
        width: maxed === "paint" ? root.width : 800
        height: maxed === "paint" ? root.height - 48 : 600
        z: topWin === "paint" ? 5 : 1
        visible: paintOpen && !isMinimized("paint")
    }
    ShutdownDialog {
        id: shutdownDlg
        anchors.centerIn: parent
        z: 20
        open: root.shutdownOpen
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        z: 19
        opacity: shutdownOpen ? 0.45 : 0.0
        visible: opacity > 0.0
        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }
    }

    Taskbar {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 48
        clockText: timeText
        dateText: dateText
        startTint: accent
        align: taskAlign
        pinFilesOpen: filesOpen
        pinFilesActive: filesOpen && !isMinimized("files")
        pinStoreOpen: storeOpen
        pinStoreActive: storeOpen && !isMinimized("store")
        pinTerminalOpen: terminalOpen
        pinTerminalActive: terminalOpen && !isMinimized("terminal")
        pinSettingsOpen: settingsOpen
        pinSettingsActive: settingsOpen && !isMinimized("settings")
    }

    // ---- Alt-Tab switcher ----
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: altTabShown ? 0.55 : 0.0
        visible: altTabShown
    }
    AltTab {
        id: switcher
        anchors.centerIn: parent
        visible: altTabShown
        selected: altTabIndex
    }

    // ---- wiring: shell ----
    Connections {
        target: bar.startMouse
        function onClicked() {
            var was = menuOpen;
            closeFlyouts();
            menuOpen = !was;
        }
    }
    Connections {
        target: bar.clockMouse
        function onClicked() {
            var was = calOpen;
            closeFlyouts();
            calOpen = !was;
        }
    }
    Connections {
        target: bar.trayMouse
        function onClicked() {
            var was = trayOpen;
            closeFlyouts();
            trayOpen = !was;
        }
    }
    Connections {
        target: bar.pinFilesMouse
        function onClicked() { pinClicked("files", filesOpen); }
    }
    Connections {
        target: bar.pinStoreMouse
        function onClicked() { pinClicked("store", storeOpen); }
    }
    Connections {
        target: bar.pinTerminalMouse
        function onClicked() { pinClicked("terminal", terminalOpen); }
    }
    Connections {
        target: bar.pinSettingsMouse
        function onClicked() { pinClicked("settings", settingsOpen); }
    }
    Connections {
        target: cal.prevMouse
        function onClicked() {
            calOffset -= 1;
            rebuildCalendar();
        }
    }
    Connections {
        target: cal.nextMouse
        function onClicked() {
            calOffset += 1;
            rebuildCalendar();
        }
    }
    Connections {
        target: tray.notifBtnMouse
        function onClicked() {
            trayOpen = false;
            notifOpen = true;
        }
    }
    Connections {
        target: tray.brightSlider
        function onMoved() {
            if (helix) {
                helix.setBrightness(tray.brightSlider.value);
            }
        }
    }
    Connections {
        target: tray.volSlider
        function onMoved() {
            if (helix) {
                helix.setVolume(tray.volSlider.value);
            }
        }
    }
    Connections {
        target: notif.brightSlider
        function onMoved() {
            if (helix) {
                helix.setBrightness(notif.brightSlider.value);
            }
        }
    }
    Connections {
        target: settingsWin.brightSlider
        function onMoved() {
            if (helix) {
                helix.setBrightness(settingsWin.brightSlider.value);
            }
        }
    }
    Connections {
        target: settingsWin.volSlider
        function onMoved() {
            if (helix) {
                helix.setVolume(settingsWin.volSlider.value);
            }
        }
    }
    Connections {
        target: settingsWin.resCombo
        function onActivated(index) {
            if (helix) {
                helix.setMode(settingsWin.resolutions[index]);
            }
        }
    }
    Connections {
        target: notif.wifiMouse
        function onClicked() {
            wifiOn = !wifiOn;
            if (helix) {
                helix.setWifi(wifiOn);
            }
        }
    }
    Connections {
        target: tray.wifiMouse
        function onClicked() {
            wifiOn = !wifiOn;
            if (helix) {
                helix.setWifi(wifiOn);
            }
        }
    }
    Connections {
        target: settingsWin.wifiToggleMouse
        function onClicked() {
            wifiOn = !wifiOn;
            if (helix) {
                helix.setWifi(wifiOn);
            }
        }
    }
    Connections {
        target: notif.btMouse
        function onClicked() { btOn = !btOn; }
    }
    Connections {
        target: notif.nightMouse
        function onClicked() { nightOn = !nightOn; }
    }
    Connections {
        target: notif.clearMouse
        function onClicked() { cleared = true; }
    }
    Connections {
        target: lock.signInMouse
        function onClicked() { unlocked = true; }
    }

    // ---- wiring: start menu launches ----
    Connections {
        target: menu.tileFilesMouse
        function onClicked() { openApp("files"); }
    }
    Connections {
        target: menu.tileStoreMouse
        function onClicked() { openApp("store"); }
    }
    Connections {
        target: menu.tileTerminalMouse
        function onClicked() { openApp("terminal"); }
    }
    Connections {
        target: menu.tileCalcMouse
        function onClicked() { openApp("calc"); }
    }
    Connections {
        target: menu.tileTaskmgrMouse
        function onClicked() { openApp("taskmgr"); }
    }
    Connections {
        target: menu.tileSettingsMouse
        function onClicked() { openApp("settings"); }
    }
    Connections {
        target: menu.tilePaintMouse
        function onClicked() { openApp("paint"); }
    }
    Connections {
        target: menu.rowFilesMouse
        function onClicked() { openApp("files"); }
    }
    Connections {
        target: menu.rowStoreMouse
        function onClicked() { openApp("store"); }
    }
    Connections {
        target: menu.rowSettingsMouse
        function onClicked() { openApp("settings"); }
    }
    Connections {
        target: menu.rowPaintMouse
        function onClicked() { openApp("paint"); }
    }
    Connections {
        target: menu.powerMouse
        function onClicked() { openApp("shutdown"); }
    }
    Connections {
        target: menu.showAllMouse
        function onClicked() { menuView = "all"; }
    }
    Connections {
        target: menu.backMouse
        function onClicked() { menuView = "main"; }
    }
    Connections {
        target: menu.allFilesMouse
        function onClicked() { openApp("files"); }
    }
    Connections {
        target: menu.allStoreMouse
        function onClicked() { openApp("store"); }
    }
    Connections {
        target: menu.allTerminalMouse
        function onClicked() { openApp("terminal"); }
    }
    Connections {
        target: menu.allCalcMouse
        function onClicked() { openApp("calc"); }
    }
    Connections {
        target: menu.allTaskmgrMouse
        function onClicked() { openApp("taskmgr"); }
    }
    Connections {
        target: menu.allSettingsMouse
        function onClicked() { openApp("settings"); }
    }
    Connections {
        target: menu.allPaintMouse
        function onClicked() { openApp("paint"); }
    }

    // ---- wiring: window chrome ----
    Connections {
        target: settingsWin.closeMouse
        function onClicked() { settingsOpen = false; }
    }
    Connections {
        target: settingsWin.minMouse
        function onClicked() { minimizeApp("settings"); }
    }
    Connections {
        target: settingsWin.maxMouse
        function onClicked() { toggleMax("settings"); }
    }
    Connections {
        target: filesWin.closeMouse
        function onClicked() { filesOpen = false; }
    }
    Connections {
        target: filesWin.minMouse
        function onClicked() { minimizeApp("files"); }
    }
    Connections {
        target: filesWin.maxMouse
        function onClicked() { toggleMax("files"); }
    }
    Connections {
        target: storeWin.closeMouse
        function onClicked() { storeOpen = false; }
    }
    Connections {
        target: storeWin.minMouse
        function onClicked() { minimizeApp("store"); }
    }
    Connections {
        target: storeWin.maxMouse
        function onClicked() { toggleMax("store"); }
    }
    Connections {
        target: terminalWin.closeMouse
        function onClicked() { terminalOpen = false; }
    }
    Connections {
        target: terminalWin.minMouse
        function onClicked() { minimizeApp("terminal"); }
    }
    Connections {
        target: terminalWin.maxMouse
        function onClicked() { toggleMax("terminal"); }
    }
    Connections {
        target: calcWin.closeMouse
        function onClicked() { calcOpen = false; }
    }
    Connections {
        target: calcWin.minMouse
        function onClicked() { minimizeApp("calc"); }
    }
    Connections {
        target: calcWin.maxMouse
        function onClicked() { toggleMax("calc"); }
    }
    Connections {
        target: taskmgrWin.closeMouse
        function onClicked() { taskmgrOpen = false; }
    }
    Connections {
        target: taskmgrWin.minMouse
        function onClicked() { minimizeApp("taskmgr"); }
    }
    Connections {
        target: taskmgrWin.maxMouse
        function onClicked() { toggleMax("taskmgr"); }
    }
    Connections {
        target: paintWin.closeMouse
        function onClicked() { paintOpen = false; }
    }
    Connections {
        target: paintWin.minMouse
        function onClicked() { minimizeApp("paint"); }
    }
    Connections {
        target: paintWin.maxMouse
        function onClicked() { toggleMax("paint"); }
    }

    // ---- wiring: settings pages ----
    Connections {
        target: settingsWin.sideWifiMouse
        function onClicked() { settingsPage = "wifi"; }
    }
    Connections {
        target: settingsWin.sideBtMouse
        function onClicked() { settingsPage = "bt"; }
    }
    Connections {
        target: settingsWin.sideDisplayMouse
        function onClicked() { settingsPage = "display"; }
    }
    Connections {
        target: settingsWin.sideSoundMouse
        function onClicked() { settingsPage = "sound"; }
    }
    Connections {
        target: settingsWin.sidePowerMouse
        function onClicked() { settingsPage = "power"; }
    }
    Connections {
        target: settingsWin.sidePersonalMouse
        function onClicked() { settingsPage = "personal"; }
    }
    Connections {
        target: settingsWin.sideAccountsMouse
        function onClicked() { settingsPage = "accounts"; }
    }
    Connections {
        target: settingsWin.sideAppsMouse
        function onClicked() { settingsPage = "apps"; }
    }
    Connections {
        target: settingsWin.sideUpdatesMouse
        function onClicked() { settingsPage = "updates"; }
    }
    Connections {
        target: settingsWin.sideAboutMouse
        function onClicked() { settingsPage = "about"; }
    }
    Connections {
        target: settingsWin.btToggleMouse
        function onClicked() { btOn = !btOn; }
    }
    Connections {
        target: settingsWin.sw0Mouse
        function onClicked() { wallpaperTheme = 0; }
    }
    Connections {
        target: settingsWin.sw1Mouse
        function onClicked() { wallpaperTheme = 1; }
    }
    Connections {
        target: settingsWin.sw2Mouse
        function onClicked() { wallpaperTheme = 2; }
    }
    Connections {
        target: settingsWin.sw3Mouse
        function onClicked() { wallpaperTheme = 3; }
    }
    Connections {
        target: settingsWin.ac0Mouse
        function onClicked() { accent = "#00F0FF"; }
    }
    Connections {
        target: settingsWin.ac1Mouse
        function onClicked() { accent = "#C6FF00"; }
    }
    Connections {
        target: settingsWin.ac2Mouse
        function onClicked() { accent = "#B44DFF"; }
    }
    Connections {
        target: settingsWin.saveNameMouse
        function onClicked() {
            if (settingsWin.userNameField !== "") {
                userName = settingsWin.userNameField;
            }
        }
    }
    Connections {
        target: settingsWin.checkUpdatesMouse
        function onClicked() {
            updatesText = "Checking for updates...";
            updatesChecked = false;
            if (helix) {
                helix.checkUpdates();
            } else {
                updatesText = "You're up to date. Helix watches over this system.";
                updatesChecked = true;
            }
        }
    }
    Connections {
        target: helix
        function onUpdatesReady(text) {
            updatesText = text;
            updatesChecked = true;
        }
    }
    Connections {
        target: helix
        function onWifiReady(nets) {
            wifiNetworks = nets;
        }
    }
    Connections {
        target: settingsWin.alignCenterMouse
        function onClicked() { taskAlign = "center"; }
    }
    Connections {
        target: settingsWin.alignLeftMouse
        function onClicked() { taskAlign = "left"; }
    }

    // ---- wiring: store + shutdown ----
    Connections {
        target: storeWin.installMouse
        function onClicked() {
            storeInstalling = true;
            storeProgress = 0.0;
            storeInstalled = false;
        }
    }
    Connections {
        target: shutdownDlg.sleepMouse
        function onClicked() {
            shutdownOpen = false;
            if (helix) {
                helix.power("sleep");
            }
        }
    }
    Connections {
        target: shutdownDlg.restartMouse
        function onClicked() {
            shutdownOpen = false;
            if (helix) {
                helix.power("reboot");
            }
        }
    }
    Connections {
        target: shutdownDlg.shutMouse
        function onClicked() {
            shutdownOpen = false;
            if (helix) {
                helix.power("off");
            }
        }
    }
    Connections {
        target: shutdownDlg.cancelMouse
        function onClicked() { shutdownOpen = false; }
    }

    // ---- wiring: first-run wizard ----
    Connections {
        target: oobe.nextMouse
        function onClicked() { if (oobeStep < 3) { oobeStep += 1; } }
    }
    Connections {
        target: oobe.backMouse
        function onClicked() { if (oobeStep > 0) { oobeStep -= 1; } }
    }
    Connections {
        target: oobe.finishMouse
        function onClicked() { oobeDone = true; }
    }

    // ---- lock screen ----
    LockScreen {
        id: lock
        anchors.fill: parent
        lockClockText: timeText
        lockDateText: lockDateText
        userLabel: userName
        accent: root.accent
        opacity: unlocked ? 0.0 : 0.96
        visible: opacity > 0.0
        Behavior on opacity {
            NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
        }
    }

    // ---- first-run wizard ----
    OOBE {
        id: oobe
        anchors.fill: parent
        visible: !oobeDone
        step: root.oobeStep
        networks: wifiNetworks
    }

    // ---- Alt-Tab keys ----
    Keys.onPressed: (event) => {
        if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Tab) {
            altTabShown = true;
            altTabIndex = (altTabIndex + 1) % 3;
            event.accepted = true;
        }
    }
    Keys.onReleased: (event) => {
        if (altTabShown && event.key === Qt.Alt) {
            altTabShown = false;
            var names = ["files", "store", "terminal"];
            openApp(names[altTabIndex]);
            altTabIndex = 0;
            event.accepted = true;
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            timeText = Qt.formatTime(d, "hh:mm");
            dateText = Qt.formatDate(d, "M/d/yyyy");
            lockDateText = Qt.formatDate(d, "dddd, MMMM d");
            rebuildCalendar();
            if (storeInstalling) {
                storeProgress += 0.2;
                if (storeProgress >= 1.0) {
                    storeProgress = 1.0;
                    storeInstalling = false;
                    storeInstalled = true;
                }
            }
            if (helix) {
                tick += 1;
                var b = helix.battery();
                battInfo = b.pct + "%";
                battState = b.state === "Charging" ? "charging" : "discharging";
                var v = helix.volume();
                if (v >= 0) {
                    volLevel = v;
                }
                var br = helix.brightness();
                if (br >= 0) {
                    brightLevel = br;
                }
                procs = helix.processes();
                homeFiles = helix.listDir(filesPath);
                refreshFilesCrumb();
                var modes = helix.screenModes();
                if (modes.length > 0) {
                    resolutions = modes;
                }
                if (tick % 15 === 0) {
                    helix.refreshWifi();
                }
            }
        }
    }

    Component.onCompleted: {
        rebuildCalendar();
        forceActiveFocus();
        if (helix) {
            userName = helix.userName();
            helix.refreshWifi();
        }
    }
}
