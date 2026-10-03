import SwiftUI

/// Plain system form: this is a utility screen, not part of the weather experience,
/// so it uses standard backgrounds rather than the sky.
struct ContactUsView: View {
  @StateObject var vm = ContactUsVM()

  var body: some View {
    Form {
      Section {
        field(placeholder: "Name", text: $vm.name, identifier: "userName",
              isValid: vm.isNameValid(), error: "* only letters (a-z) are allowed.")
          .textContentType(.name)
        field(placeholder: "Email", text: $vm.email, identifier: "userEmail",
              isValid: vm.isEmailValid(), error: "* only letters (a-z), numbers (0-9) and periods(.) are allowed.")
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
          .textContentType(.emailAddress)
        field(placeholder: "Phone Number", text: $vm.phoneNumber, identifier: "userPhoneNumber",
              isValid: vm.isPhoneNumberValid(), error: "* only numbers (0-9) are allowed.")
          .keyboardType(.numbersAndPunctuation)
          .textContentType(.telephoneNumber)
      }

      Section {
        Button {
          vm.share = vm.isDataComplete
        } label: {
          Text("Send")
            .frame(maxWidth: .infinity)
        }
        .disabled(!vm.isDataComplete)
        .accessibilityIdentifier("sendButton")
        .accessibilityHint(vm.isDataComplete ? "Sends your contact information to customer support" : "Complete all fields correctly to enable sending")
      }

      if vm.isDataComplete && vm.share {
        Section {
          Label("Thanks. Customer support will contact you soon.", systemImage: "checkmark.circle.fill")
            .accessibilityIdentifier("successMessage")
        }
      }
    }
    // Inside the Settings sheet, let the sheet's glass/material show through like the parent form.
    .scrollContentBackground(.hidden)
    .navigationTitle("Contact Us")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func field(placeholder: LocalizedStringKey, text: Binding<String>, identifier: String,
                     isValid: Bool, error: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: DS.Space.xs) {
      TextField(placeholder, text: text)
        .accessibilityIdentifier(identifier)
        .frame(minHeight: DS.Size.minTarget)
      // Only flag a field once someone has typed in it — an untouched form isn't an error.
      if !isValid && !text.wrappedValue.isEmpty {
        Text(error)
          .font(.footnote.weight(.semibold))
          .foregroundStyle(Color(uiColor: .systemRed))
      }
    }
    // .contain (not .combine) keeps the text field itself focusable and editable.
    .accessibilityElement(children: .contain)
  }
}

#Preview {
  NavigationStack { ContactUsView() }
}
