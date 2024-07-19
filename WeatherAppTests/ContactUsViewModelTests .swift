import Testing
@testable import WeatherApp

struct ContactUsVMSwiftTests {
  let contactUsVM = ContactUsVM()
  @Test("Validate name - valid input",
        arguments: [("John Doe")])
  func name_validation_with_valid_input(name: String) {
    contactUsVM.name = name
    #expect(contactUsVM.isNameValid())
  }
  
  @Test("Validate name - invalid input",
        arguments: ["   " , "Joh", "John! Doe" ])
  func name_validation_with_invalid_input(name: String) {
    contactUsVM.name = name
    #expect(!contactUsVM.isNameValid())
  }
  
  @Test("Validate email - valid input",
        arguments: [("john@gmail.com")])
  func email_validation_with_valid_input(email: String) {
    contactUsVM.email = email
    #expect(contactUsVM.isEmailValid())
  }
  
  @Test("Validate email - invalid input",
        arguments: ["   " , "johngmail.com", "john.doe@" ])
  func email_validation_with_invalid_input(email: String) {
    contactUsVM.email = email
    #expect(!contactUsVM.isEmailValid())
  }
  
  @Test("Validate phone number - valid input",
        arguments: [("1234567890")])
  func phone_number_validation_with_valid_input(phone: String) {
    contactUsVM.phoneNumber = phone
    #expect(contactUsVM.isPhoneNumberValid())
  }
  
  @Test("Validate phone number - invalid input",
        arguments: ["   " , "12345678", "12345678901", "1234567890@#" ])
  func phone_number_validation_with_invalid_input(phone: String) {
    contactUsVM.phoneNumber = phone
    #expect(!contactUsVM.isPhoneNumberValid())
  }
}
