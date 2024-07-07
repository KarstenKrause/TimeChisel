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
    @Environment(\.timeTrackingStatus) var trackingStatus
    @State private var showingTimeIsTrackingAlert: Bool = false
    @State private var showingDeleteAlert = false
    @State var job: JobModel
    @State private var showUpdateJobView: Bool = false
    
    var body: some View {
        VStack {
            Text("Job Overview...")
            List {
                ForEach(job.timeTrackings, id: \.self) { item in
                    Text("\(item.workingTime)")
                }
            }
        }
        .navigationTitle(job.companyName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    trackingStatus.isTracking ? showingTimeIsTrackingAlert.toggle() : showUpdateJobView.toggle()
                }, label: {
                    Image(systemName: "pencil.circle")
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    trackingStatus.isTracking ? showingTimeIsTrackingAlert.toggle() : showingDeleteAlert.toggle()
                    
                }, label: {
                    Image(systemName: "trash.circle")
                        .foregroundColor(.red)
                })
                .alert("Jobs können während einer Zeiterfassung nicht bearbeitet oder gelöscht werden.", isPresented: $showingTimeIsTrackingAlert) {
                    Button("OK", role: .cancel) {
                        showingTimeIsTrackingAlert = false
                    }
                }
                .alert("Der Job und alle zusammenhängenden Daten werden hierdurch entgültig gelöscht.", isPresented: $showingDeleteAlert) {
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
    let testJob = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: HourlyRate(value: 25.0, currency: .EUR))
    
    return JobDetailView(job: testJob)
    
}
