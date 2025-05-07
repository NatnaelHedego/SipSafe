import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateGroupView: View {
    var onGroupCreated: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var groupName: String = ""
    @State private var participantEmail: String = ""
    @State private var participants: [String] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 16) {
            TextField("Group Name", text: $groupName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Participant Email", text: $participantEmail)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Add Participant") {
                addParticipantByEmail()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            if !participants.isEmpty {
                VStack(alignment: .leading) {
                    Text("Participants:")
                        .font(.headline)
                    ForEach(participants, id: \.self) { uid in
                        Text(uid)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }

            Button("Create Group") {
                // Set the alert message and show the alert immediately when the button is clicked
                alertMessage = "Group successfully created!"
                showAlert = true
                createGroup()  // Continue creating the group in the background
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Create Group")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Info"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    onGroupCreated?()
                    dismiss()
                }
            )
        }
    }

    private func addParticipantByEmail() {
        guard !participantEmail.isEmpty else {
            alertMessage = "Please enter an email."
            showAlert = true
            return
        }

        db.collection("users")
            .whereField("email", isEqualTo: participantEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    alertMessage = "Error finding user: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let document = snapshot?.documents.first else {
                    alertMessage = "No user found with this email."
                    showAlert = true
                    return
                }

                let uid = document.documentID

                if !participants.contains(uid) {
                    participants.append(uid)
                    alertMessage = "Participant added!"
                } else {
                    alertMessage = "Participant already added."
                }

                showAlert = true
                participantEmail = ""
            }
    }

    private func createGroup() {
        guard !groupName.isEmpty else {
            alertMessage = "Group name cannot be empty."
            showAlert = true
            return
        }

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            alertMessage = "User not authenticated."
            showAlert = true
            return
        }

        let allParticipants = Array(Set(participants + [currentUserID]))

        let groupData: [String: Any] = [
            "name": groupName,
            "participantIDs": allParticipants
        ]

        db.collection("groups").addDocument(data: groupData) { error in
            // No need to update the alert here anymore; the alert already shows immediately when the button is clicked
        }
    }
}

