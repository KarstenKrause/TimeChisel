//
//  MainView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            TimeTrackingView()
                .tabItem {
                    Label("Zeiterfassung", systemImage: "clock.arrow.2.circlepath")
                }
            
            JobsView()
                .tabItem {
                    Label("Jobs", systemImage: "building.2")
                }
            
            HistoryView()
                .tabItem {
                    Label("Verlauf", systemImage: "calendar")
                }
            
            
            SettingsView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainView()
}
