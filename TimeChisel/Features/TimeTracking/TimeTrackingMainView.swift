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
    
    //TODO: Fetch all Jobs in MainView and pass it through this component
    //@State private var selectedJob: JobModel
    @State private var selectedJob = ""
   
    var body: some View {
        // TODO: Job Picker
        
        
        VStack {
            if (!isWorkingTimerRunning) {
                Form {
                    Section("Job auswählen") {
                        Picker("Jobs", selection: $selectedJob) {
                            ForEach(jobs, id: \.self) { job in
                                Text("\(job.companyName)")
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    self.isWorkingTimerRunning.toggle()
                }, label: {
                    Text("Starten")
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(Color.green)
                        .foregroundColor(.primary)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.black, lineWidth: 1.5)
                                .padding(4)
                        )
                })
                Spacer()
            } else {
                TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning)
            }
        }
    }
    
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let container = try! ModelContainer(for: JobModel.self, configurations: config)
    
    let job: JobModel = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30)
    
    container.mainContext.insert(job)
    
    return TimeTrackingMainView().modelContainer(container)
}
