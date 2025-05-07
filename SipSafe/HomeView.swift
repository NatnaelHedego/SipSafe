import SwiftUI
import UserNotifications

struct HomeView: View {
    @State private var selectedDate = Date()
    @State private var startTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!
    @State private var endTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    @State private var showSuccessAlert = false

    var body: some View {
        VStack {
            DatePicker("Choose a date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            HStack {
                DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                    .padding()
                    .frame(maxWidth: .infinity)

                DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            Button(action: saveButtonClicked) {
                Text("Save")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 20)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Check-In")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Your check-in was successfully set!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func saveButtonClicked() {
        requestNotificationPermissions { granted in
            if granted {
                scheduleNotification()
                DispatchQueue.main.async {
                    showSuccessAlert = true
                }
            } else {
                print("Permission denied.")
            }
        }
    }

    private func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Error requesting notification permissions: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }

    private func scheduleNotification() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let selectedDateOnly = calendar.date(from: selectedDateComponents) else { return }

        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        guard let combinedStartTime = calendar.date(
            bySettingHour: startComponents.hour!,
            minute: startComponents.minute!,
            second: 0,
            of: selectedDateOnly
        ) else { return }

        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        guard var combinedEndTime = calendar.date(
            bySettingHour: endComponents.hour!,
            minute: endComponents.minute!,
            second: 0,
            of: selectedDateOnly
        ) else { return }

        if combinedEndTime <= combinedStartTime {
            combinedEndTime = calendar.date(byAdding: .day, value: 1, to: combinedEndTime)!
        }

        let timeInterval = combinedEndTime.timeIntervalSince(combinedStartTime)
        let randomOffset = TimeInterval.random(in: 0...timeInterval)
        let randomNotificationTime = combinedStartTime.addingTimeInterval(randomOffset)

        let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: randomNotificationTime)

        let content = UNMutableNotificationContent()
        content.title = "Time to Check-In!"
        content.body = "Your check-in is at \(formattedTime(randomNotificationTime))."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(formattedTime(randomNotificationTime))")
            }
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
}

