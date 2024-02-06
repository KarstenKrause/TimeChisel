//
//  AddJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 04.02.24.
//

import SwiftUI

struct AddJobView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var companyName = ""
    @State private var jobTitle = ""
    @State private var hourlyWage = ""
    @State private var workingHoursPerWeek = 1
    @State private var workingDaysPerWeek = 1
    @State private var pauseMinutesPerDay = 0
    
    var body: some View {
        NavigationView {
            
            Form {
                Section("Jobinfos") {
                    TextField("Name des Unternehmens", text: $companyName)
                    TextField("Job-Titel", text: $companyName)
                    TextField("Stundenlohn", text: $hourlyWage)
                }
                
                Section("Arbeitszeiten") {
                    Picker("Stunden pro Woche", selection: $workingHoursPerWeek) {
                        ForEach(1...60, id: \.self) {
                            Text("\($0) Stunden")
                        }
                    }
                    
                    Picker("Tage pro Woche", selection: $workingDaysPerWeek) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0) Tage")
                        }
                    }
                    
                    Picker("Pause am Tag", selection: $pauseMinutesPerDay) {
                        ForEach(0...4, id: \.self) { index in
                            let minutes = index * 30
                            Text("\(minutes) Minuten")
                        }
                    }
                    
                }
                
                Section {
                    HStack{
                        Button(action: {
                            print("add Job button tapped")
                        }, label: {
                            Text("Speichern")
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                        })
    
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
