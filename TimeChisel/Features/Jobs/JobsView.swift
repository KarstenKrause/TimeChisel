//
//  CompanyProfilesView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI

struct JobsView: View {
    @State private var showAddJobView = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Section {
                    Text("Test")
                }
                
            }
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddJobView.toggle()
                    }, label: {
                        Label("Einstellungen", systemImage: "plus.circle")
                    })
                    
                }
            }
        }
        .sheet(isPresented: $showAddJobView, content: {
            AddJobView()
        })
        
    }
}

#Preview {
    JobsView()
}
