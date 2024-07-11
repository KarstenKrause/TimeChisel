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
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }
    
    var body: some View {
        VStack {
            Text("Job Overview...")
            List {
                ForEach(job.timeTrackings, id: \.self) { item in
                    Text("\(item.workingTime)")
                }
            }
            Section {
                HStack {
                    GroupBox("Überstunden") {
                        Text("20")
                    }.groupBoxStyle(.jobDetails)
                    
                    GroupBox("Arbeitszeit") {
                        Text("340")
                    }.groupBoxStyle(.jobDetails)
                }
            }
            .padding()
            
            Section(header: Text("Zeitaufzeichnungen").font(.headline)) {
                            Text("Gesamte Arbeitszeit: \(job.totalWorkingTime.hours) Stunden \(job.totalWorkingTime.minutes) Minuten")
                            Text("Überstunden: \(job.totalWorkingTime.overtime.hours) Stunden \(job.totalWorkingTime.overtime.minutes) Minuten")
//                            if let lastTracking = job.timeTrackings.last {
//                                Text("Letzte Arbeitszeiterfassung: \(lastTracking.date, formatter: dateFormatter)")
//                            }
                Text("Letzte Arbeitszeiterfassung: \(Date(), formatter: dateFormatter)")
                
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
    let testJob = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25.0, currency: .EUR))
    
    return JobDetailView(job: testJob)
    
}


struct JobDetailsGroupboxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .bold()
            configuration.content
                .font(.title)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

extension GroupBoxStyle where Self == JobDetailsGroupboxStyle {
    static var jobDetails: JobDetailsGroupboxStyle { .init() }
}
