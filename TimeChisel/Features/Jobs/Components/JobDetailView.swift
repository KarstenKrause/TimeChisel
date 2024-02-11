//
//  JobDetailView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 11.02.24.
//

import SwiftUI

struct JobDetailView: View {
    @State var job: JobModel
    @State private var showUpdateJobView: Bool = false
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            Text("Job Overview...")
        }
        .navigationTitle(job.companyName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showUpdateJobView.toggle()
                }, label: {
                    Label("Einstellungen", systemImage: "pencil.circle")
                })
            }
        }
        .sheet(isPresented: $showUpdateJobView, content: {
            UpdateJobView(jobModel: job, path: $path)
        })
    }
}

//#Preview {
//    let testJob = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", hourlyWage: "52", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30)
//    JobDetailView(job: testJob)
//}
