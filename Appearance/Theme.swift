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
        if userDefaults.string(forKey: "AppleInterfaceStyle") == "Dark" {
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
    private var cancellables = [AnyCancellable]()

    var theme: Theme

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.theme = Theme(colorScheme: .decode(userDefaults: userDefaults))
    }

    func add(callback: @escaping (Theme) -> Void) {
        callbacks.append(callback)
    }

    func start() {
        cancellables.append(CombineTimer(interval: 1).publisher.sink { now in
            self.theme.colorScheme = .decode()
        })

        cancellables.append(theme.objectDidChange.sink { theme in
            os_log("Current colorscheme is %@", theme.colorScheme.description)
            for callback in self.callbacks {
                callback(theme)
            }
        })
    }
}
