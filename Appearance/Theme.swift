import Foundation
import Combine
import SwiftUI
import os.log

struct Theme {
    var objectDidChange = PassthroughSubject<Theme, Never>()

    var colorScheme: ColorScheme {
        didSet {
            if oldValue != colorScheme {
                objectDidChange.send(self)
            }
        }
    }
}

extension ColorScheme {
    static func decode(
        userDefaults: UserDefaults = UserDefaults.standard
    ) -> ColorScheme {
        decode(name: userDefaults.string(forKey: "AppleInterfaceStyle") ?? "")
    }

    static func decode(name: String) -> ColorScheme {
        if name == "Dark" {
            return .dark
        }

        return .light
    }

    var description: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        @unknown default:
            return "Unknown"
        }
    }
}

class ThemeCallbackManager {
    private let userDefaults: UserDefaults
    private var callbacks = [(Theme) -> Void]()
    private var observer: NSKeyValueObservation?

    var theme: Theme

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.theme = Theme(colorScheme: .decode(userDefaults: userDefaults))
    }

    deinit {
        observer?.invalidate()
    }

    func add(callback: @escaping (Theme) -> Void) {
        callbacks.append(callback)
    }

    private func executeCallbacks() {
        os_log("Will execute callbacks, colorscheme is %@", theme.colorScheme.description)
        for callback in callbacks {
            callback(theme)
        }
        os_log("Did execute callbacks")
    }

    func start() {
        observer?.invalidate()
        observer = NSApp.observe(\.effectiveAppearance, options: [.new, .old, .initial, .prior]) { [weak self] app, change in
            guard let self = self else { return }

            let newColorScheme = ColorScheme.decode()

            guard self.theme.colorScheme != newColorScheme else { return }

            self.theme.colorScheme = .decode()
            self.executeCallbacks()
        }
    }
}
