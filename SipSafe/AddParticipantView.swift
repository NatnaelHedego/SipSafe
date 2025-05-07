import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddParticipantView: View {
    @State private var participantEmail: String = ""
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var showLeaveAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var groupId: String
    var onAddParticipant: () -> Void

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Participant Email", text: $participantEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top)

            Button(action: addParticipant) {
                Text("Add Participant")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
            }

            Divider().padding(.vertical, 10)

            Button(action: {
                showLeaveAlert = true
            }) {
                Text("Leave Group")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $showLeaveAlert) {
            Alert(
                title: Text("Leave Group"),
                message: Text("Are you sure you want to leave this group?"),
                primaryButton: .destructive(Text("Leave")) {
                    leaveGroup()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func addParticipant() {
        guard !participantEmail.isEmpty else {
            errorMessage = "Please enter an email."
            successMessage = nil
            return
        }

        db.collection("users").whereField("email", isEqualTo: participantEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = "Failed to find participant: \(error.localizedDescription)"
                    successMessage = nil
                    return
                }

                guard let document = snapshot?.documents.first else {
                    errorMessage = "No user found with this email."
                    successMessage = nil
                    return
                }

                let participantID = document.documentID // UID is the document ID
                addParticipantToGroup(participantID: participantID)
            }
    }

    private func addParticipantToGroup(participantID: String) {
        db.collection("groups").document(groupId).updateData([
            "participantIDs": FieldValue.arrayUnion([participantID])
        ]) { error in
            if let error = error {
                errorMessage = "Error adding participant: \(error.localizedDescription)"
                successMessage = nil
            } else {
                successMessage = "Participant added successfully!"
                errorMessage = nil
                onAddParticipant()
            }
        }
    }

    private func leaveGroup() {
        guard let currentUserID = auth.currentUser?.uid else { return }

        db.collection("groups").document(groupId).updateData([
            "participantIDs": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            if let error = error {
                errorMessage = "Error leaving group: \(error.localizedDescription)"
            } else {
                presentationMode.wrappedValue.dismiss() // Close the view
            }
        }
    }
}

