Feature: LaunchAtLogin

The application should be launched at login if user activates that feature.
Note that the Mac App Store guidelines requires launch at login functionality
to be enabled in response to a user action.

  Scenario: Launching the application for first time
    Given the application is installed but never opened
    And I open the application
    When I click the status bar item
    Then "Launch at login" should be "off"

  Scenario: Activating launch at login
    Given the application is installed but never opened
    And I open the application
    When I click the status bar item
    And I click "Launch at login"
    Then "Launch at login" should be "on"

  Scenario: Inactivating launch at login
    Given the application is installed but never opened
    And I open the application
    When I click the status bar item
    And I click "Launch at login"
    And I click the status bar item
    And I click "Launch at login"
    Then "Launch at login" should be "off"
