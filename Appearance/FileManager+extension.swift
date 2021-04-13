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
        guard let path = ProcessInfo.processInfo.environment["APPEARANCE_CONFIG_PATH"] else {
            return homeDirectoryForCurrentUser
                .appendingPathComponent(".config")
                .appendingPathComponent("appearance")
        }

        guard let url = URL(string: path) else {
            fatalError("APPEARANCE_CONFIG_PATH didn't conform to valid URL")
        }

        return url
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
