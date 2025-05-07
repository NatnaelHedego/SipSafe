import FirebaseFirestore
import FirebaseAuth

// Message model for Firestore
struct Message: Identifiable {
    var id: String
    var senderID: String
    var senderEmail: String // Add senderEmail to the model
    var content: String
    var timestamp: Timestamp
}

// Group model for Firestore
struct FirestoreGroup: Identifiable {
    var id: String
    var name: String
    var participants: [String] // Array of user IDs
}

