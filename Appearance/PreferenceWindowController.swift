import Cocoa
import SwiftUI

class PreferenceWindowController: NSWindowController {
    typealias OnCloseClosure = (PreferenceWindowController?) -> Void
    private var onClose: OnCloseClosure

    init(onClose: @escaping OnCloseClosure) {
        self.onClose = onClose

        let contentView = PreferencesView()

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false
        )
        window.center()
        window.setFrameAutosaveName("Preferences")
        window.contentView = NSHostingView(rootView: contentView)
        window.title = NSLocalizedString("Preferences",
                                         comment: "Preferences window title")


        super.init(window: window)

        window.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PreferenceWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        onClose(window?.windowController as? PreferenceWindowController)
    }
}
