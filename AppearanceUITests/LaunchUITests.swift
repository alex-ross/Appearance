//
//  LaunchUITests.swift
//  AppearanceUITests
//
//  Created by Alexander Ross on 2021-04-12.
//  Copyright © 2021 Alexander Ross. All rights reserved.
//

import XCTest

class LaunchUITests: AppearanceUITests {
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch],
                    block: app.launch)
        }
    }

    func testCreatesHookDirectoryOnLaunch() {
        app.launch()

        let hooksPath = configPath
            .appendingPathComponent("hooks", isDirectory: true)

        XCTAssertTrue(FileManager.default.fileExists(atPath: hooksPath.relativePath))
    }

    func testCurrentFileOnLaunchWhenDarkMode() throws {
        let currentColorschemePath = configPath
            .appendingPathComponent("current", isDirectory: false)
        let currentColorScheme = UserDefaults
            .standard
            .string(forKey: "AppleInterfaceStyle") ?? "Light"

        app.launch()
        let content = try String(contentsOfFile: currentColorschemePath.relativePath, encoding: .utf8)

        XCTAssertEqual(currentColorScheme, content)
    }
}
