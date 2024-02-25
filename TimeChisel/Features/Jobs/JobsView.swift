//
//  CompanyProfilesView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI
import SwiftData

struct JobsView: View {
    @Environment(\.modelContext) var context
    @State private var showingAlert = false
    @State private var showAddJobView = false
    @State private var jobToUpdate: JobModel?
    @State private var jobToDelete: JobModel?
    @Query(sort: \JobModel.companyName) var jobs: [JobModel]
    
    var body: some View {
        NavigationStack {
            
            if(jobs.isEmpty) {
                VStack {
                    Text("Bevor Arbeitszeiten getrackt werden können, füge zunächst einen Job hinzu.")
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    Button("Job hinzufüfgen") {
                        showAddJobView.toggle()
                    }
                }
                .padding()
                
            } else {
                List {
                    ForEach(jobs) { job in
                        NavigationLink(value: job) {
                            Text(job.companyName)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(action: {
                                        showingAlert = true
                                        jobToDelete = job
                                    }, label: {
                                        Text("Löschen")
                                    })
                                    .tint(.red)
                                    
                                    Button(action: {
                                        jobToUpdate = job
                                    }, label: {
                                        Text("Bearbeiten")
                                    })
                                    .tint(.blue)
                                }
                                .alert("Der Job und alle zusammenhängende Daten werden hierdurch entgültig gelöscht", isPresented: $showingAlert) {
                                    Button("Löschen", role: .destructive) {
                                        context.delete(jobToDelete!)
                                    }
                                    Button("Abbrechen", role: .cancel) {}
                                }
                        }
                    }
                }
                .navigationDestination(for: JobModel.self) { job in
                    JobDetailView(job: job)
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
        }
        .sheet(isPresented: $showAddJobView, content: {
            AddJobView()
        })
        .sheet(item: $jobToUpdate) { jobModel in
            UpdateJobView(jobModel: jobModel)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let container = try! ModelContainer(for: JobModel.self, configurations: config)
    
    let job: JobModel = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30)
    
    container.mainContext.insert(job)
    
    return JobsView()
        .modelContainer(container)
}
