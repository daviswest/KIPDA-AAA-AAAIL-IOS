import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 60)

            Text("Please login to continue")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

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
                // This is where we'll handle login action
            }) {
                Text("LOGIN")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(red: 0/255, green: 129/255, blue: 246/255))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding()
    }
}
