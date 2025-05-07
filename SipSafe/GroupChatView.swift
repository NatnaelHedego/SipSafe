import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroupChatView: View {
    var groupId: String
    var groupName: String

    @State private var messages: [Message] = []
    @State private var messageContent: String = ""
    @State private var isLoading: Bool = false
    @State private var showAddParticipantView: Bool = false

    private let db = Firestore.firestore()

    init(groupId: String, groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
    }

    var body: some View {
        VStack {
            // Message list view
            ScrollView {
                ForEach(messages) { message in
                    VStack(alignment: .leading) {
                        Text(message.senderEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(message.content)
                            .padding(.bottom, 5)
                    }
                    .padding()
                }
            }

            // Message input field and send button
            HStack {
                TextField("Type a message...", text: $messageContent)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                Button(action: sendMessage) {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(messageContent.isEmpty)
            }
            .padding()
        }
        .navigationTitle(groupName)
        .navigationBarItems(trailing:
            Button(action: {
                showAddParticipantView = true
            }) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
            }
        )
        .sheet(isPresented: $showAddParticipantView) {
            AddParticipantView(groupId: groupId) {
                // Optional callback when a participant is added
                print("Participant added or group updated.")
            }
        }
        .onAppear(perform: loadMessages)
    }

    func loadMessages() {
        isLoading = true

        db.collection("messages")
            .whereField("groupID", isEqualTo: groupId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting messages: \(error)")
                    isLoading = false
                    return
                }

                self.messages = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let senderID = data["senderID"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())

                    let senderEmail = Auth.auth().currentUser?.email ?? "Unknown User"

                    return Message(id: id, senderID: senderID, senderEmail: senderEmail, content: content, timestamp: timestamp)
                } ?? []

                isLoading = false
            }
    }

    func sendMessage() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let messageData: [String: Any] = [
            "senderID": currentUserID,
            "content": messageContent,
            "timestamp": Timestamp(),
            "groupID": groupId
        ]

        db.collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                self.messageContent = ""
            }
        }
    }
}

