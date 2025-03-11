import SwiftUI

struct LoginView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var schoolName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var uwNetID: String = ""

    var body: some View {
        ZStack {
            // Background image
            Image("background_image_name") // Replace with your image name
                .resizable() 
                .scaledToFill() // Ensures the image fills the screen
                .edgesIgnoringSafeArea(.all) // Makes the image extend to all edges

            // Content in the foreground
            VStack {
                // First row: First Name and Last Name
                HStack {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color.white.opacity(0.8)) // Semi-transparent background for input
                        .cornerRadius(10)
                        .frame(height: 50)

                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .frame(height: 50)
                }
                .padding([.leading, .trailing])

                // Second row: College/School Name
                TextField("College/School Name", text: $schoolName)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .frame(height: 50)
                    .padding([.leading, .trailing, .top])

                // Third row: Username and Password
                HStack {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .frame(height: 50)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .frame(height: 50)
                }
                .padding([.leading, .trailing, .top])

                // Fourth row: UW Net ID
                TextField("UW Net ID", text: $uwNetID)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .frame(height: 50)
                    .padding([.leading, .trailing, .top])

                // Sign Up Button
                Button(action: signUp) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.leading, .trailing, .top])
                }

                Spacer()
            }
            .navigationTitle("Sign Up")
            .padding()
        }
    }

    private func signUp() {
        // Handle sign up logic here
        print("Sign up with details: \(firstName), \(lastName), \(schoolName), \(username), \(password), \(uwNetID)")
    }
}

#Preview {
    LoginView()
}