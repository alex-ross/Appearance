//
//  AppearanceUITests.swift
//  AppearanceUITests
//
//  Created by Alexander Ross on 2020-01-25.
//  Copyright © 2020 Alexander Ross. All rights reserved.
//

import XCTest

class AppearanceUITests: XCTestCase {

    lazy var configPath: URL = {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }()

    lazy var launchEnvironment: [String : String] = {
        ["APPEARANCE_CONFIG_PATH": configPath.absoluteString]
    }()

    lazy var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchEnvironment = launchEnvironment
        return app
    }()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
