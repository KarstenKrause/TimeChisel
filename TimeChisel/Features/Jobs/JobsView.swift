//
//  CompanyProfilesView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI
import SwiftData

struct JobsView: View {
    @State private var showAddJobView = false
    @Query(sort: \JobModel.companyName) var jobs: [JobModel]
    
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(jobs) { job in
                    Text(job.companyName)
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
