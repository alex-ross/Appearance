//
//  HooksController.swift
//  Appearance
//
//  Created by Alexander Ross on 2021-02-07.
//  Copyright © 2021 Alexander Ross. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

class HooksController {
    private let userDefaults: UserDefaults
    private var hooks = [(Theme) -> Void]()
    private var observer: NSKeyValueObservation?

    var theme: Theme

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.theme = Theme(colorScheme: .decode(userDefaults: userDefaults))
    }

    deinit {
        observer?.invalidate()
    }

    func add(hook: @escaping (Theme) -> Void) {
        hooks.append(hook)
    }

    func executeHooks() {
        os_log("Will execute hooks, colorscheme is %@", theme.colorScheme.description)
        for hook in hooks {
            hook(theme)
        }
        os_log("Did execute hooks")
    }

    func start() {
        observer?.invalidate()

        // Do this once on launche to ensure correct color scheme is submitted
        // to hooks if computer has been turned off.
        setColorSchemeAndEnqueueHooks()

        observer = NSApp.observe(\.effectiveAppearance) { [weak self] app, change in
            guard let self = self else { return }
            self.setColorSchemeAndEnqueueHooks()
        }
    }

    private func setColorSchemeAndEnqueueHooks() {
        let newColorScheme = ColorScheme.decode()
        guard theme.colorScheme != newColorScheme else { return }
        theme.colorScheme = .decode()

        DispatchQueue.global().async(execute: executeHooks)
    }
}
