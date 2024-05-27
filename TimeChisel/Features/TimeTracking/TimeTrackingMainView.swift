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
                        List(jobs, id: \.self) { job in
                            HStack {
                                Text(job.companyName)
                                Spacer()
                                if job == selectedJob {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedJob = job
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    if selectedJob != nil {
                        self.isWorkingTimerRunning.toggle()
                    }
                }, label: {
                    Text("Starten")
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(selectedJob != nil ? Color.green : Color.gray)
                        .foregroundColor(.primary)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.black, lineWidth: 1.5)
                                .padding(4)
                        )
                })
                .disabled(selectedJob == nil)
                Spacer()
            } else {
                TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning, selectedJob: $selectedJob)
            }
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let container = try! ModelContainer(for: JobModel.self, configurations: config)
    
    let job: JobModel = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: HourlyRate(value: 25.0, currency: .EUR))
    
    container.mainContext.insert(job)
    
    return TimeTrackingMainView().modelContainer(container)
}
