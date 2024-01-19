import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("We're glad you're here")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 60)

            Text("Please fill out some details to register")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            TextField("Username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)

            Button(action: {
                // This is where we'll handle register action
            }) {
                Text("REGISTER")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding()
    }
}
