//
//  TimeTrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI
import SwiftData

struct TimeTrackingMainView: View {
    @Environment(\.modelContext) var context
    @Environment(\.timeTrackingStatus) var trackingStatus
    @State private var isWorkingTimerRunning: Bool = false
    @State private var isPauseTimerRunning: Bool = false
    @State private var timeTrackingCanceled: Bool = false
    @Query(sort: \JobModel.companyName) var jobs: [JobModel]
    
    @State private var selectedJob: JobModel? = nil
    
    var body: some View {
        VStack {
            if !isWorkingTimerRunning {
                Form {
                    Section("Job auswählen") {
                        Picker("Jobs", selection: $selectedJob) {
                            ForEach(jobs, id: \.self) { job in
                                Text(job.companyName).tag(job as JobModel?)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    startTracking()
                }, label: {
                    Text("Starten")
                        .bold()
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(selectedJob != nil ? .green.opacity(0.30) : .gray.opacity(0.35))
                        .foregroundColor(Color("lightGreen"))
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color("customBW"), lineWidth: 1.5)
                                .padding(4)
                        )
                })
                .disabled(selectedJob == nil)
                Spacer()
            } else {
                TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning, selectedJob: $selectedJob)
            }
        }
        .onAppear {
            if !jobs.isEmpty {
                selectedJob = jobs[0]
            }
        }
    }
    
    private func startTracking() {
        if selectedJob != nil {
            isWorkingTimerRunning = true
            trackingStatus.isTracking = true
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let container = try! ModelContainer(for: JobModel.self, configurations: config)
    
    let job: JobModel = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25.0, currency: .EUR))
    
    container.mainContext.insert(job)
    
    return TimeTrackingMainView().modelContainer(container)
}
