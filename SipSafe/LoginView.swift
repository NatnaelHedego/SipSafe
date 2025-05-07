import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isErrorPresented = false
    @State private var isLoading = false
    @State private var isCreatingAccount = false // Track whether the user is creating an account

    var body: some View {
        VStack {
            Text(isCreatingAccount ? "Create an Account" : "Welcome to SipSafe")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom, 10)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom, 20)

            if isLoading {
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                Button(action: {
                    if isCreatingAccount {
                        signUpUser()
                    } else {
                        loginUser()
                    }
                }) {
                    Text(isCreatingAccount ? "Create Account" : "Login")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 10)
            }
            
            Button(action: toggleCreateAccount) {
                Text(isCreatingAccount ? "Already have an account? Login" : "Don't have an account? Sign up")
                    .foregroundColor(.blue)
            }

            if isErrorPresented {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
        .alert(isPresented: $isErrorPresented) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func loginUser() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                isErrorPresented = true
            } else {
                isLoading = false
                isLoggedIn = true // Set the binding to true to show the main view
            }
        }
    }

    func signUpUser() {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                isErrorPresented = true
            } else {
                isLoading = false
                // After successful sign-up, switch to login mode
                isCreatingAccount = false
                errorMessage = "Account created successfully! Please log in."
                isErrorPresented = true
            }
        }
    }

    // Toggle between login and create account mode
    func toggleCreateAccount() {
        isCreatingAccount.toggle()
    }
}

