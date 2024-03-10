import SwiftUI

struct ContactUsView: View {
  @StateObject var vm = ContactUsVM()

  var body: some View {
    ZStack {
      SkyImageView()
      Form {
        Section{
          VStack(alignment: .leading){
            TextField("Name",text: $vm.name)
              .accessibilityIdentifier("userName")
            if vm.isNameValid() == false{
              Text("* only letters (a-z) are allowed.")
                .foregroundColor(.red)
            }
          }
          VStack(alignment: .leading){
            TextField("Email",text: $vm.email)
              .accessibilityIdentifier("userEmail")
              .keyboardType(.emailAddress)
              .textInputAutocapitalization(.never)
            if vm.isEmailValid() == false{
              Text("* only letters (a-z), numbers (0-9) and periods(.) are allowed.")
                .foregroundColor(.red)
            }
          }
          VStack(alignment: .leading){
            TextField("Phone Number",text: $vm.phoneNumber)
              .accessibilityIdentifier("userPhoneNumber")
              .keyboardType(.numbersAndPunctuation)
            if vm.isPhoneNumberValid() == false {
              Text("* only numbers (0-9) are allowed.")
                .foregroundColor(.red)
            }
          }
        }

        Section{
          HStack{
            Spacer()
            Button("Send") {
              DispatchQueue.main.async {
                if vm.isDataComplete {
                  vm.share = true
                }
                else {
                  vm.share = false
                }
              }
            }
            .accessibilityIdentifier("sendButton")
            Spacer()
          }
        }.disabled(!vm.isDataComplete)

        if vm.isDataComplete && vm.share {
          Section{
            Text("Thank you for sharing your contact details with us someone form customer support will contact you soon...")
              .accessibilityIdentifier("successMessage")
          }
        }
      }
      .navigationTitle("Contact us")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ContactUsView_Previews: PreviewProvider {
  static var previews: some View {
    ContactUsView()
  }
}
