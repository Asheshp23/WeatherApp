import Testing
@testable import WeatherApp

struct ContactUsVMSwiftTests {
  @Test
  func IsNameValid() {
    let contactUsVM = ContactUsVM()
    // Test valid name
    contactUsVM.name = "John Doe"
    #expect(contactUsVM.isNameValid())

    // Test name with only spaces
    contactUsVM.name = "    "
    #expect(contactUsVM.isNameValid() == false)

    // Test name that is too short
    contactUsVM.name = "Joh"
    #expect(contactUsVM.isNameValid() == false)

    // Test name with special characters
    contactUsVM.name = "John! Doe"
    #expect(contactUsVM.isNameValid() == false)
  }

  @Test
  func isEmailValid() {
    let contactUsVM = ContactUsVM()
    // Test valid email
    contactUsVM.email = "john.doe@gmail.com"
    #expect(contactUsVM.isEmailValid())

    // Test email with only spaces
    contactUsVM.email = "    "
    #expect(!contactUsVM.isEmailValid())

    // Test email without @ symbol
    contactUsVM.email = "johngmail.com"
    #expect(!contactUsVM.isEmailValid())

    // Test email without domain
    contactUsVM.email = "john.doe@"
    #expect(!contactUsVM.isEmailValid())
  }
  
  @Test
  func isPhoneNumberValid() {
    let contactUsVM = ContactUsVM()
    // Test valid phone number
    contactUsVM.phoneNumber = "1234567890"
    #expect(contactUsVM.isPhoneNumberValid())

    // Test phone number with only spaces
    contactUsVM.phoneNumber = "    "
    #expect(!contactUsVM.isPhoneNumberValid())

    // Test phone number that is too short
    contactUsVM.phoneNumber = "12345678"
    #expect(!contactUsVM.isPhoneNumberValid())

    // Test phone number that is too long
    contactUsVM.phoneNumber = "12345678901"
    #expect(!contactUsVM.isPhoneNumberValid())

    // Test phone number with special characters
    contactUsVM.phoneNumber = "1234567890@#"
    #expect(!contactUsVM.isPhoneNumberValid())
  }
}
