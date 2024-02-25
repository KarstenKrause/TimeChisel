//
//  EditJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 10.02.24.
//

import SwiftUI

struct UpdateJobView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Bindable var jobModel: JobModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Jobinfos") {
                    TextField("Name des Unternehmens", text: $jobModel.companyName)
                    TextField("Job-Titel", text: $jobModel.jobTitle)
                }
                
                Section("Arbeitszeiten") {
                    Picker("Stunden pro Woche", selection: $jobModel.workingHoursPerWeek) {
                        ForEach(1...60, id: \.self) {
                            Text("\($0) Stunden")
                        }
                    }
                    
                    Picker("Tage pro Woche", selection: $jobModel.workingDaysPerWeek) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0) Tage")
                        }
                    }
                    
                    Picker("Pause am Tag", selection: $jobModel.pauseMinutesPerDay) {
                        ForEach(0...4, id: \.self) { index in
                            let minutes = index * 30
                            Text("\(minutes) Minuten")
                        }
                    }
                }
                
                Section {
                    HStack{
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Fertig")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                    }
                }
                .buttonStyle(.borderless)
                
            }
            .navigationTitle("Bearbeiten")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Schließen", systemImage: "xmark.circle.fill")
                    })
                }
            }
        }
    }
}

//#Preview {
//    EditJobView()
//}
