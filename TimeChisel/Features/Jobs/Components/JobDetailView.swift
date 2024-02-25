//
//  JobDetailView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 11.02.24.
//

import SwiftUI
 
struct JobDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var showingAlert = false
    @State var job: JobModel
    @State private var showUpdateJobView: Bool = false
    
    var body: some View {
        VStack {
            Text("Job Overview...")
        }
        .navigationTitle(job.companyName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showUpdateJobView.toggle()
                }, label: {
                    Image(systemName: "pencil.circle")
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAlert.toggle()
                }, label: {
                    Image(systemName: "trash.circle")
                        .foregroundColor(.red)
                })
                .alert("Der Job und alle zusammenhängende Daten werden hierdurch entgültig gelöscht.", isPresented: $showingAlert) {
                    Button("Löschen", role: .destructive) {
                        context.delete(job)
                        dismiss()
                    }
                    Button("Abbrechen", role: .cancel) {}
                }
            }
        }
        .sheet(isPresented: $showUpdateJobView, content: {
            UpdateJobView(jobModel: job)
        })
    }
}

#Preview {
    let testJob = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30)
    
    return JobDetailView(job: testJob)
    
}
