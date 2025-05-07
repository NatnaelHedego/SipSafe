import SwiftUI
import UserNotifications

struct NotiView: View {
    @State private var pendingRequests: [UNNotificationRequest] = []

    var body: some View {
        VStack {
            if pendingRequests.isEmpty {
                Text("No scheduled notifications.")
                    .padding()
            } else {
                List {
                    ForEach(pendingRequests, id: \.identifier) { request in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your notification")
                                .font(.headline)

                            if let triggerDate = extractTriggerDate(from: request.trigger) { // Use the new function
                                Text("Scheduled for: \(formattedDate(triggerDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Scheduled time unavailable")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Button(action: {
                                cancelNotification(id: request.identifier)
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadPendingNotifications()
        }
    }

    private func loadPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                pendingRequests = requests
            }
        }
    }

    private func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        loadPendingNotifications()
    }

    private func extractTriggerDate(from trigger: UNNotificationTrigger?) -> Date? {
        guard let calendarTrigger = trigger as? UNCalendarNotificationTrigger else {
            return nil
        }
        return Calendar.current.date(from: calendarTrigger.dateComponents)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}
