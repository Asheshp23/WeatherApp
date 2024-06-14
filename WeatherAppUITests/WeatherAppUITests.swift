import XCTest

@testable import WeatherApp

@MainActor
class WeatherNetwrokTechAssessmentUITests: XCTestCase {
  let app = XCUIApplication()

  func testSetting() throws {
    app.launch()
    let showSettingsButton = app.buttons["showSettings"]
    XCTAssertTrue(showSettingsButton.waitForExistence(timeout: 2))
    showSettingsButton.tap()
    app.segmentedControls["temperatureUnit"].tap()
  }

  func testPhotos() throws {
    app.launch()
  }

  func testContactUs() throws {
    app.launch()
    let goToContactUsButton = app.buttons["goToContactUs"]
    XCTAssertTrue(goToContactUsButton.waitForExistence(timeout: 2))
    goToContactUsButton.tap()

    let userNameInputField = app.textFields["userName"]
    let userphoneNumberInputField = app.textFields["userPhoneNumber"]
    let userEmailInputTextField = app.textFields["userEmail"]

    XCTAssertTrue(userNameInputField.waitForExistence(timeout: 2))
    XCTAssertTrue(userphoneNumberInputField.waitForExistence(timeout: 2))
    XCTAssertTrue(userEmailInputTextField.waitForExistence(timeout: 2))

    userNameInputField.tap()
    userNameInputField.typeText("Ashesh Patel")
    userEmailInputTextField.tap()
    userEmailInputTextField.typeText("asheshp23@gmail.com")
    userphoneNumberInputField.tap()
    userphoneNumberInputField.typeText("1234567890")


    let sendButton = app.buttons["sendButton"]
    XCTAssertTrue(sendButton.waitForExistence(timeout: 2))
    sendButton.tap()


  }

  func testCityListDetail() throws {
    app.launch()
    app.buttons["goToCityList"].tap()
  }

  func testWeatherView() {
    app.launch()
    // Test that the city label displays the correct city
//    let cityLabel = app.staticTexts["Brampton"]
//    XCTAssertTrue(cityLabel.exists)

    // Test that the temperature label displays the correct temperature
    let temperatureLabel = app.staticTexts["°C"]
    XCTAssertTrue(temperatureLabel.exists)

  }
}
