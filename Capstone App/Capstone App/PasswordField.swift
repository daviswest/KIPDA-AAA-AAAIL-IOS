import SwiftUI

struct PasswordField: View {
    var placeholder: String
    @Binding var password: String
    @State private var showPassword = false

    var body: some View {
        HStack {
            if showPassword {
                TextField(placeholder, text: $password)
                    .autocapitalization(.none)
            } else {
                SecureField(placeholder, text: $password)
                    .autocapitalization(.none)
            }

            Button(action: {
                self.showPassword.toggle()
            }) {
                Image(systemName: self.showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}
