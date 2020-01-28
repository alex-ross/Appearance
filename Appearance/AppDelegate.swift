import Cocoa
import LaunchAtLogin
import os.log
import SwiftUI

// TODO: Listen when color scheme changes
// TODO: Allow to add script to execute when color scheme is changed
// TODO: Improve logotype
// TODO: Add localization

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?
    lazy var appMenu: NSMenu = {
        let toggleColorSceme = NSMenuItem(
            title: "Toggle color scheme",
            action: #selector(toggleDarkMode),
            keyEquivalent: ""
        )

        let toggleLaunchAtLogin = NSMenuItem(
            title: "Launch at login",
            action: #selector(launchAtLogin(sender:)),
            keyEquivalent: ""
        )

        let terminator = NSMenuItem(
            title: "Quit",
            action: #selector(quit(sender:)),
            keyEquivalent: ""
        )

        if LaunchAtLogin.isEnabled {
            toggleLaunchAtLogin.state = .on
        }

        let menu = NSMenu(title: "Appearance")
        menu.addItem(toggleColorSceme)
        menu.addItem(.separator())
        menu.addItem(toggleLaunchAtLogin)
        menu.addItem(.separator())
        menu.addItem(terminator)

        return menu
    }()

    func applicationDidFinishLaunching(_: Notification) {
        statusItem = makeStatusItem()
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

    func makeWindow() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
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
