import SwiftUI
import FirebaseFirestore

struct MainTabView: View {
    @State private var selectedGroupId: String? = nil
    @State private var selectedGroupName: String? = nil
    @State private var isShowingGroupChat = false

    var body: some View {
        NavigationStack {
            TabView {
                // Home tab
                SimpleHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                // Check-In tab
                HomeView()
                    .tabItem {
                        Label("Check-In", systemImage: "checkmark.circle.fill")
                    }

                // Notifications tab
                NotiView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell.fill")
                    }

                // Group Chats tab — using bindings
                GroupChatListView(
                    selectedGroupId: $selectedGroupId,
                    selectedGroupName: $selectedGroupName
                )
                .tabItem {
                    Label("Group Chats", systemImage: "bubble.left.and.bubble.right.fill")
                }
            }
            .navigationDestination(isPresented: $isShowingGroupChat) {
                if let groupId = selectedGroupId, let groupName = selectedGroupName {
                    GroupChatView(groupId: groupId, groupName: groupName)
                }
            }
            .onChange(of: selectedGroupId) { newGroupId in
                if let id = newGroupId {
                    fetchGroupName(groupId: id) { name in
                        self.selectedGroupName = name
                        self.isShowingGroupChat = true
                    }
                }
            }
        }
    }

    func fetchGroupName(groupId: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("groups").document(groupId).getDocument { document, error in
            if let document = document, document.exists {
                let name = document.data()?["name"] as? String ?? "Group Chat"
                completion(name)
            } else {
                completion("Group Chat")
            }
        }
    }
}

