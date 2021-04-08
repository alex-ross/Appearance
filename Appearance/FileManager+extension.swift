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
            .appendingPathComponent("appearance")
    }

    var hooksDirectory: URL {
        return configDirectory.appendingPathComponent("hooks")
    }

    var currentColorschemeFile: URL {
        return configDirectory.appendingPathComponent("current")
    }

    /// Prepares the file system for the application by creating needed files and directories
    func prepareConfigDirectory() {
        os_log("Will prepare config directory")
        defer { os_log("Did prepare config directory") }

        let path = hooksDirectory
        if !FileManager.default.fileExists(atPath: path.relativePath) {
            do {
                try FileManager.default.createDirectory(atPath: path.relativePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log("error: %@", error.localizedDescription)
            }
        }
    }
}
