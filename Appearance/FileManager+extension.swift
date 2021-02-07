//
//  FileManager+extension.swift
//  Appearance
//
//  Created by Alexander Ross on 2021-02-04.
//  Copyright © 2021 Alexander Ross. All rights reserved.
//

import Foundation
import os.log
import ShellOut

extension FileManager {
    var configDirectory: URL {
        return homeDirectoryForCurrentUser
            .appendingPathComponent(".config")
            .appendingPathComponent("apperance")
    }

    var callbackScriptDirectory: URL {
        return configDirectory.appendingPathComponent("scripts")
    }

    /// Prepares the file system for the application by creating needed files and directories
    func prepareConfigDirectory() {
        os_log("Will prepare config directory")
        defer { os_log("Did prepare config directory") }

        let path = callbackScriptDirectory
        if !FileManager.default.fileExists(atPath: path.relativePath) {
            do {
                try FileManager.default.createDirectory(atPath: path.relativePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log("error: %@", error.localizedDescription)
            }
        }
    }
}
