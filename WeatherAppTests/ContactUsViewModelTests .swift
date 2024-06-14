import Testing
@testable import WeatherApp

struct ContactUsVMSwiftTests {
  let contactUsVM = ContactUsVM()
  @Test("Validate name",
        arguments: [("John Doe")])
  func nameValidation(name: String) {
    contactUsVM.name = name
    #expect(contactUsVM.isNameValid())
  }
  
  @Test("Validate name for invalid inputs",
        arguments: ["   " , "Joh", "John! Doe" ])
  func nameValidationForInavalid(name: String) {
    contactUsVM.name = name
    #expect(!contactUsVM.isNameValid())
  }

  @Test("Validate email",
        arguments: [("john@gmail.com")])
  func emailValidation(email: String) {
    contactUsVM.email = email
    #expect(contactUsVM.isEmailValid())
  }
  
  @Test("Validate email for invalid inputs",
        arguments: ["   " , "johngmail.com", "john.doe@" ])
  func emailValidationForInavalid(email: String) {
    contactUsVM.email = email
    #expect(!contactUsVM.isEmailValid())
  }
  
  @Test("Validate phone number",
        arguments: [("1234567890")])
  func phoneNumberValidation(phone: String) {
    contactUsVM.phoneNumber = phone
    #expect(contactUsVM.isPhoneNumberValid())
  }
  
  @Test("Validate phone number for invalid inputs",
        arguments: ["   " , "12345678", "12345678901", "1234567890@#" ])
  func phoneNumberValidationForInavalid(phone: String) {
    contactUsVM.phoneNumber = phone
    #expect(!contactUsVM.isPhoneNumberValid())
  }
}
