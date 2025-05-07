import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroupChatListView: View {
    @Binding var selectedGroupId: String?
    @Binding var selectedGroupName: String?

    @State private var groups: [FirestoreGroup] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isCreateGroupSheetPresented: Bool = false

    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading groups...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if groups.isEmpty {
                Text("No group chats found.")
                    .foregroundColor(.gray)
            } else {
                List(groups) { group in
                    NavigationLink(destination: GroupChatView(groupId: group.id, groupName: group.name)) {
                        Text(group.name)
                            .padding()
                    }
                    .buttonStyle(PlainButtonStyle())  // To prevent it from being styled as a button
                }
            }

            // Create Group Button
            Button(action: {
                isCreateGroupSheetPresented.toggle()
            }) {
                Text("Create Group")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .sheet(isPresented: $isCreateGroupSheetPresented) {
                CreateGroupView(onGroupCreated: loadGroups) // Pass loadGroups to reload the group list
            }
        }
        .navigationTitle("Group Chats")
        .onAppear(perform: loadGroups)
    }

    private func loadGroups() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        db.collection("groups")
            .whereField("participantIDs", arrayContains: currentUserID)
            .getDocuments { snapshot, error in
                isLoading = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                self.groups = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? "Unnamed Group"
                    let participants = data["participantIDs"] as? [String] ?? []

                    return FirestoreGroup(id: id, name: name, participants: participants)
                } ?? []
            }
    }
}

