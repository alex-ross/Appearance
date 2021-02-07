//
//  ColorScheme+extension.swift
//  Appearance
//
//  Created by Alexander Ross on 2021-02-07.
//  Copyright © 2021 Alexander Ross. All rights reserved.
//

import Foundation
import SwiftUI

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
