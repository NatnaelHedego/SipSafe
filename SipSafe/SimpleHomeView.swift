import SwiftUI
import UserNotifications

struct SimpleHomeView: View {
    @State private var pendingRequests: [UNNotificationRequest] = []
    @State private var goToCheckIn = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to SipSafe!")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Stay safe, stay connected. Here are your current check-in notifications:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                    // Notifications section
                    if pendingRequests.isEmpty {
                        Text("You have no scheduled notifications.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(pendingRequests, id: \.identifier) { request in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("📍 Check-In Reminder")
                                        .font(.headline)

                                    if let triggerDate = extractTriggerDate(from: request.trigger) {
                                        Text("Scheduled for: \(formattedDate(triggerDate))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Scheduled time unavailable")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

                                    Divider()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Home")
            .onAppear {
                loadPendingNotifications()
            }
        }
    }

    // MARK: - Notification Helpers

    private func loadPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                pendingRequests = requests
            }
        }
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

#Preview {
    SimpleHomeView()
}
