import Cocoa
import LaunchAtLogin
import os.log
import ShellOut

// TODO: Allow to add script to execute when color scheme is changed
// TODO: Improve logotype
// TODO: Add sparkle for updates if it can't be released on App Store https://sparkle-project.org

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var preferenceWindowController: PreferenceWindowController?

    var statusItem: NSStatusItem?
    lazy var appMenu: NSMenu = {
        let toggleColorSceme = NSMenuItem(
            title: NSLocalizedString("Toggle color scheme", comment: "Menu item"),
            action: #selector(toggleDarkMode),
            keyEquivalent: ""
        )

        let toggleLaunchAtLogin = NSMenuItem(
            title: NSLocalizedString("Launch at login", comment: "Menu item"),
            action: #selector(launchAtLogin(sender:)),
            keyEquivalent: ""
        )

        let preferences = NSMenuItem(
            title: NSLocalizedString("Preferences...", comment: "Menu item"),
            action: #selector(openPreferences),
            keyEquivalent: ""
        )

        let terminator = NSMenuItem(
            title: NSLocalizedString("Quit", comment: "Menu item"),
            action: #selector(quit(sender:)),
            keyEquivalent: ""
        )

        if LaunchAtLogin.isEnabled {
            toggleLaunchAtLogin.state = .on
        }

        let menu = NSMenu(title: NSLocalizedString("Appearance",
                                                   comment: "Menu title"))
        menu.addItem(toggleColorSceme)
        menu.addItem(.separator())
        menu.addItem(toggleLaunchAtLogin)
        menu.addItem(preferences)
        menu.addItem(.separator())
        menu.addItem(terminator)

        return menu
    }()

    var themeCallbackManager = ThemeCallbackManager(userDefaults: .standard)

    func applicationDidFinishLaunching(_: Notification) {
        FileManager.default.prepareConfigDirectory()

        statusItem = makeStatusItem()
        themeCallbackManager.start()

        themeCallbackManager.add { [weak self] theme in
            let enumerator = FileManager.default.enumerator(atPath: FileManager.default.callbackScriptDirectory.relativePath)
            while let element = enumerator?.nextObject() as? String {
                os_log("Iterating over file %@", element.debugDescription)
                if let fType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType{
                    switch fType {
                    case .typeRegular:
                        os_log("Will execute file \"%@\" with arguments [\"%@\"]", element, theme.colorScheme.description)
                        defer { os_log("Did execute file: %@", element) }

                        do {
                            let output = try shellOut(to: "./\(element)", arguments: [theme.colorScheme.description], at: FileManager.default.callbackScriptDirectory.relativePath)
                            os_log("%@", output)
                        } catch {
                            os_log("error: %@", error.localizedDescription)
                            self?.alert(title: "Error executing: \(element)", body: error.localizedDescription)
                        }
                    case .typeDirectory:
                        os_log("warning: %@ is a directory, will be skipped", element)
                    default:
                        os_log("warning: Unknown file type for %@", element)
                    }
                }
            }
        }
    }

    func alert(title: String, body: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = body
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
        }
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    /// Note that it may be failed (return nil) if the status bar is already full packed with many other status
    /// bar items.
    func makeStatusItem() -> NSStatusItem? {
        let statusItem = NSStatusBar.system.statusItem(withLength: -1)

        guard let button = statusItem.button else {
            os_log(.error, "Status bar item failed. Try to remove some status bar item first")
            return nil
        }

        let image = NSImage(named: "StatusItemButton")!
        image.size = .init(width: 18, height: 18)

        button.image = image
        button.target = self
        button.action = #selector(displayMenu)

        return statusItem
    }

    @objc func openPreferences() {
        if preferenceWindowController == nil {
            preferenceWindowController = PreferenceWindowController { controller in
                self.preferenceWindowController = nil
            }
        }

        preferenceWindowController?.window?.makeKeyAndOrderFront(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    @objc func displayMenu() {
        guard let button = statusItem?.button else { return }
        let x = button.frame.origin.x
        let y = button.frame.origin.y - 5
        let location = button.superview!.convert(NSMakePoint(x, y), to: nil)
        let w = button.window!
        let event = NSEvent.mouseEvent(with: .leftMouseUp,
                                       location: location,
                                       modifierFlags: NSEvent.ModifierFlags(rawValue: 0),
                                       timestamp: 0,
                                       windowNumber: w.windowNumber,
                                       context: nil,
                                       eventNumber: 0,
                                       clickCount: 1,
                                       pressure: 0)!
        NSMenu.popUpContextMenu(appMenu, with: event, for: button)
    }

    @objc func toggleDarkMode() {
        let source = #"""
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
        """#

        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)

        if let error = error {
            print(error)
        }
    }

    @objc func launchAtLogin(sender: NSMenuItem) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled

        if LaunchAtLogin.isEnabled {
            sender.state = .on
        } else {
            sender.state = .off
        }
    }

    @objc func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
}
