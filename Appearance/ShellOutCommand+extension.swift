//
//  ShellOutCommand+extension.swift
//  Appearance
//
//  Created by Alexander Ross on 2021-02-07.
//  Copyright © 2021 Alexander Ross. All rights reserved.
//

import Foundation
import ShellOut

extension ShellOutCommand {
    static func hook(filename: String, theme: Theme) -> ShellOutCommand {
        let command = [
            "/bin/bash",
            "-C",
            "\"\(filename)\"",
            theme.colorScheme.description
        ].joined(separator: " ")

        return ShellOutCommand(string: command)
    }
}
