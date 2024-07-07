//
//  TimeChiselApp.swift
//  TimeChisel
//
//  Created by Karsten Krause on 01.02.24.
//

import SwiftUI
import SwiftData

@main
struct TimeChiselApp: App {
    @Bindable var timeTrackingStatus = TimeTrackingStatus()
    
    let jobsContainer: ModelContainer = {
            let schema = Schema([JobModel.self, TimeTrackingModel.self])
            do {
                //let config = ModelConfiguration(...) --> add config and migrationplan for widgets iCloud etc
                let container = try ModelContainer(for: schema, configurations: [])
                return container
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }()
        
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.timeTrackingStatus, timeTrackingStatus)
        }
        .modelContainer(jobsContainer)

    }
}
