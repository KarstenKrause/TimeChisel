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
    @State private var jobToUpdate: JobModel?
    @State private var navigationPath = NavigationPath()
    @Query(sort: \JobModel.companyName) var jobs: [JobModel]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(jobs) { job in
                    
                    NavigationLink(value: job) {
                        Text(job.companyName)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(action: {
                                    jobToUpdate = job
                                }, label: {
                                    Text("Bearbeiten")
                                })
                                .tint(.blue)
                            }
                    }
                }
            }
            .navigationDestination(for: JobModel.self, destination: { job in
                JobDetailView(job: job, path: $navigationPath)
            })
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
        .sheet(item: $jobToUpdate) { jobModel in
            UpdateJobView(jobModel: jobModel, path: $navigationPath)
        }
 
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, configurations: config)
    
    let job: JobModel = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", hourlyWage: "25", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30)
    
    container.mainContext.insert(job)
    
    return JobsView()
        .modelContainer(container)
}
