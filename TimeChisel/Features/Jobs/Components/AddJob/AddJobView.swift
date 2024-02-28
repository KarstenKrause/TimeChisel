//
//  AddJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 04.02.24.
//

import SwiftUI

struct AddJobView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Bindable var jobVM = JobViewModel(
        companyName: "",
        jobTitle: "",
        workingHoursPerWeek: 1,
        workingDaysPerWeek: 1,
        pauseMinutesPerDay: 0
    )
    
    var jobs: [JobModel] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Jobinfos") {
                    TextField("Name des Unternehmens", text: $jobVM.companyName)
                    TextField("Job-Titel", text: $jobVM.jobTitle)
                }
                
                Section("Arbeitszeiten") {
                    Picker("Stunden pro Woche", selection: $jobVM.workingHoursPerWeek) {
                        ForEach(1...60, id: \.self) {
                            Text("\($0) Stunden")
                        }
                    }
                    
                    Picker("Tage pro Woche", selection: $jobVM.workingDaysPerWeek) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0) Tage")
                        }
                    }
                    
                    Picker("Pause am Tag", selection: $jobVM.pauseMinutesPerDay) {
                        ForEach(0...4, id: \.self) { index in
                            let minutes = index * 30
                            Text("\(minutes) Minuten")
                        }
                    }
                }
                
                Section {
                    HStack{
                        Button(action: {
                            let job: JobModel = JobModel(companyName: jobVM.companyName, jobTitle: jobVM.jobTitle, workingHoursPerWeek: jobVM.workingHoursPerWeek, workingDaysPerWeek: jobVM.workingDaysPerWeek, pauseMinutesPerDay: jobVM.pauseMinutesPerDay)
                            
                            context.insert(job)
                            try! context.save()
                            dismiss()
                        }, label: {
                            Text("Speichern")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                        })
                        .disabled((jobVM.companyName.isEmpty || jobVM.jobTitle.isEmpty))
                    }
                }
                .buttonStyle(.borderless)
            }
            .navigationTitle("Job hinzufügen")
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

#Preview {
    AddJobView()
}
