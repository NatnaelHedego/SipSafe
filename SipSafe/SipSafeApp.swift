//
//  SipSafeApp.swift
//  SipSafe
//
//  Created by Natnael Hedego on 3/10/25.
//

import SwiftUI

@main
struct SipSafeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
