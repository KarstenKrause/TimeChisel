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
    
    let jobsContainer: ModelContainer = {
        let schema = Schema([JobModel.self])
        //let config = ModelConfiguration(...) --> add config and migrationplan for widgets iCloud etc
        let container = try! ModelContainer(for: schema, configurations: [])
        
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(jobsContainer)

    }
}
