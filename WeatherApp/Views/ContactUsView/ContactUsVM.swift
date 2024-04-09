import Foundation

class ContactUsVM: ObservableObject {
  @Published var email = ""
  @Published var name  = ""
  @Published var phoneNumber = ""
  @Published var share = false
  
  var isDataComplete: Bool {
    if !isNameValid() || !isEmailValid() || !isPhoneNumberValid() {
      return false
    }
    return true
  }

  func isNameValid() -> Bool {
    let nameTest = NSPredicate(format: "SELF MATCHES %@","([A-Za-z]+ ?)*$")
    return nameTest.evaluate(with: name) && name.count > 3
  }

  func isPhoneNumberValid() -> Bool{
    let phoneNumberTest = NSPredicate(format:"SELF MATCHES %@", "[0-9]{10,10}")
    return phoneNumberTest.evaluate(with:phoneNumber) && phoneNumber.count == 10
  }

  func isEmailValid() -> Bool {
    let emailTest = NSPredicate(format: "SELF MATCHES %@",
                                "^[a-z](\\.?[a-z0-9])+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    return emailTest.evaluate(with: email)
  }
}
