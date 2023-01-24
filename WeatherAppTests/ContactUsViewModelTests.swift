import XCTest
@testable import WeatherApp

class ContactUsVMTests: XCTestCase {

  func testIsNameValid() {
    let contactUsVM = ContactUsVM()
    // Test valid name
    contactUsVM.name = "John Doe"
    XCTAssertTrue(contactUsVM.isNameValid())

    // Test name with only spaces
    contactUsVM.name = "    "
    XCTAssertFalse(contactUsVM.isNameValid())

    // Test name that is too short
    contactUsVM.name = "Joh"
    XCTAssertFalse(contactUsVM.isNameValid())

    // Test name with special characters
    contactUsVM.name = "John! Doe"
    XCTAssertFalse(contactUsVM.isNameValid())
  }

  func testIsEmailValid() {
    let contactUsVM = ContactUsVM()
    // Test valid email
    contactUsVM.email = "john.doe@gmail.com"
    XCTAssertTrue(contactUsVM.isEmailValid())

    // Test email with only spaces
    contactUsVM.email = "    "
    XCTAssertFalse(contactUsVM.isEmailValid())

    // Test email without @ symbol
    contactUsVM.email = "johngmail.com"
    XCTAssertFalse(contactUsVM.isEmailValid())

    // Test email without domain
    contactUsVM.email = "john.doe@"
    XCTAssertFalse(contactUsVM.isEmailValid())
  }

  func testIsPhoneNumberValid() {
    let contactUsVM = ContactUsVM()
    // Test valid phone number
    contactUsVM.phoneNumber = "1234567890"
    XCTAssertTrue(contactUsVM.isPhoneNumberValid())

    // Test phone number with only spaces
    contactUsVM.phoneNumber = "    "
    XCTAssertFalse(contactUsVM.isPhoneNumberValid())

    // Test phone number that is too short
    contactUsVM.phoneNumber = "12345678"
    XCTAssertFalse(contactUsVM.isPhoneNumberValid())

    // Test phone number that is too long
    contactUsVM.phoneNumber = "12345678901"
    XCTAssertFalse(contactUsVM.isPhoneNumberValid())

    // Test phone number with special characters
    contactUsVM.phoneNumber = "1234567890@#"
    XCTAssertFalse(contactUsVM.isPhoneNumberValid())
  }

  //test validation functions using mock invalid data...
  func testContactUsFormValidationWithInvalidData() {

    let contactUsVM = ContactUsVM()
    let mockName = "Joh"
    let mockEmail = "@winterfell.com"
    let mockPhone = "1234567890!"

    contactUsVM.name = mockName
    contactUsVM.email = mockEmail
    contactUsVM.phoneNumber = mockPhone

    XCTAssertFalse(contactUsVM.isNameValid())
    XCTAssertFalse(contactUsVM.isEmailValid())
    XCTAssertFalse(contactUsVM.isPhoneNumberValid())
    XCTAssertFalse(contactUsVM.isDataComplete)
  }

}
