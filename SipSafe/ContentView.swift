import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false // This tracks login status

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                MainTabView() // Show main tab view if logged in
            } else {
                LoginView(isLoggedIn: $isLoggedIn) // Pass binding of isLoggedIn
            }
        }
    }
}

