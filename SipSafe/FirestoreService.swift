import FirebaseFirestore
import FirebaseAuth

// Load messages for a specific group
func loadMessages(groupId: String, completion: @escaping ([Message]) -> Void) {
    let db = Firestore.firestore()
    let dispatchGroup = DispatchGroup()
    var messages: [Message] = []

    db.collection("messages")
        .whereField("groupID", isEqualTo: groupId)
        .order(by: "timestamp")
        .getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                completion([]) // Return empty messages array if error
                return
            }

            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let id = document.documentID
                let senderID = data["senderID"] as? String ?? ""
                let content = data["content"] as? String ?? ""
                let timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())

                // Fetch the user's display name asynchronously
                dispatchGroup.enter() // Notify the dispatch group that the task is starting

                getUserDisplayName(userID: senderID) { displayName in
                    let message = Message(id: id, senderID: senderID, senderEmail: displayName, content: content, timestamp: timestamp)
                    messages.append(message)
                    dispatchGroup.leave() // Notify the dispatch group that the task is completed
                }
            }

            // After all messages have been processed, call the completion handler
            dispatchGroup.notify(queue: .main) {
                completion(messages) // Return all the messages to the caller
            }
        }
}

// Fetch user's display name using the userID
func getUserDisplayName(userID: String, completion: @escaping (String) -> Void) {
    let db = Firestore.firestore()
    db.collection("users").document(userID).getDocument { document, error in
        if let error = error {
            print("Error fetching user data: \(error)")
            completion("Unknown") // Return a default display name in case of an error
            return
        }

        if let document = document, document.exists {
            let displayName = document.data()?["displayName"] as? String ?? "Unknown"
            completion(displayName)
        } else {
            completion("Unknown") // Return a default name if no document exists
        }
    }
}

// Add a participant to a group
func addParticipantToGroup(groupId: String, participantId: String, completion: @escaping (Bool, String) -> Void) {
    let db = Firestore.firestore()

    // Update the group document to add the participant
    db.collection("groups").document(groupId).updateData([
        "participantIDs": FieldValue.arrayUnion([participantId])
    ]) { error in
        if let error = error {
            completion(false, "Failed to add participant: \(error.localizedDescription)")
        } else {
            completion(true, "Participant added successfully!")
        }
    }
}

// Remove a participant from a group
func removeParticipantFromGroup(groupId: String, participantId: String, completion: @escaping (Bool, String) -> Void) {
    let db = Firestore.firestore()

    // Update the group document to remove the participant
    db.collection("groups").document(groupId).updateData([
        "participantIDs": FieldValue.arrayRemove([participantId])
    ]) { error in
        if let error = error {
            completion(false, "Failed to remove participant: \(error.localizedDescription)")
        } else {
            completion(true, "Participant removed successfully!")
        }
    }
}

